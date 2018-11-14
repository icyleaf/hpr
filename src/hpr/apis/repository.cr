module Hpr::API::Repositories
  # List all repositories
  class List < Salt::App
    def call(env)
      client = Client.new
      names = client.list_repositories
      repositories = names.each_with_object([] of Hash(String, String)) do |name, obj|
        obj << Utils.repository_info(name) if Git::Repo.repository_path?(name)
      end

      body = {
        total: repositories.size,
        data:  repositories,
      }.to_json

      {200, {"Content-Type" => "application/json"}, [body]}
    end
  end

  # Get a repository by given name
  class Show < Salt::App
    def call(env)
      name = env.params["name"]
      repo = Git::Repo.repository(name)
      if repo.exists?
        if repo.cloning?
          status_code = 202
          body = {
            message: "Repositoy is cloning, wait a moment.",
          }
        else
          status_code = 200
          body = Utils.repository_info(name)
        end
      else
        status_code = 404
        body = {
          message: "Not found repository: #{name}",
        }
      end

      {status_code, {"Content-Type" => "application/json"}, [body.to_json]}
    end
  end

  # Create new repository
  class Create < Salt::App
    def call(env)
      client = Client.new
      begin
        url = env.params["url"]
        name = env.params["name"]?
        create = env.params["create"]? || "true"
        clone = env.params["clone"]? || "true"

        client.create_repository(
          url, name,
          create == "true",
          clone == "true"
        )
        body = true
        status_code = 201
      rescue e : Gitlab::Error::APIError
        body = {
          message: e.message,
        }
        status_code = 400
      end

      {status_code, {"Content-Type" => "application/json"}, [body.to_json]}
    end
  end

  # Update a repository by given name
  class Update < Salt::App
    def call(env)
      client = Client.new
      client.update_repository(env.params["name"])
      {200, {"Content-Type" => "application/json"}, ["true"]}
    end
  end

  # Remove a repository by given name
  class Delete < Salt::App
    def call(env)
      client = Client.new
      client.delete_repository env.params["name"]
      {200, {"Content-Type" => "application/json"}, ["true"]}
    end
  end

  # Search repositories by name
  class Search < Salt::App
    def call(env)
      client = Client.new
      keyword = env.params["name"]
      repositories = client.search_repositories(keyword).each_with_object([] of Hash(String, String)) do |name, obj|
        obj << Utils.repository_info(name)
      end

      status_code = 200
      body = {
        total: repositories.size,
        data:  repositories,
      }

      {status_code, {"Content-Type" => "application/json"}, [body.to_json]}
    end
  end
end
