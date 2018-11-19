module Hpr::API::Repositories
  # List all repositories
  class List < Salt::App
    include Git::Helper

    def call(env)
      Raven.breadcrumbs.record do |crumb|
        crumb.category = "api"
        crumb.timestamp = Time.now
        crumb.message = "Call #{self.class} API"
      end

      client = Client.new
      names = client.list_repositories
      repositories = names.each_with_object([] of Hash(String, String)) do |name, obj|
        obj << repository_info(name) if Git::Repo.repository_path?(name)
      end

      body = {
        total: repositories.size,
        data:  repositories,
      }.to_json

      {200, {"Content-Type" => "application/json"}, [body]}
    rescue e : Exception
      Hpr.capture_exception(e, "api", params: env.params.to_h.to_s)
      body = {message: e.message}.to_json
      {400, {"Content-Type" => "application/json"}, [body]}
    end
  end

  # Get a repository by given name
  class Show < Salt::App
    include Git::Helper

    def call(env)
      # TODO: Use multiple if statements, must be extract to one.
      Raven.breadcrumbs.record do |crumb|
        crumb.category = "api"
        crumb.timestamp = Time.now
        crumb.message = "Call #{self.class} API"
      end

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
          body = repository_info(name)
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
      url = env.params["url"]
      name = env.params["name"]?
      create = env.params["create"]? || "true"
      clone = env.params["clone"]? || "true"

      3 / 0
      client = Client.new
      client.create_repository(
        url, name,
        create == "true",
        clone == "true"
      )
      body = true
      {201, {"Content-Type" => "application/json"}, [body.to_json]}
    rescue e : Gitlab::Error::APIError
      body = {
        message: e.message,
      }
      {400, {"Content-Type" => "application/json"}, [body.to_json]}
    end
  end

  # Update a repository by given name
  class Update < Salt::App
    def call(env)
      # TODO: Use multiple if statements, must be extract to one.
      name = env.params["name"]
      repo = Git::Repo.repository(name)
      if repo.exists?
        if repo.cloning?
          status_code = 202
          body = {
            message: "Repositoy is cloning, wait a moment.",
          }.to_json
        else
          status_code = 200
          client = Client.new
          client.update_repository(name)
          body = "true"
        end
      else
        status_code = 404
        body = {
          message: "Not found repository: #{name}",
        }.to_json
      end

      {status_code, {"Content-Type" => "application/json"}, [body]}
    end
  end

  # Remove a repository by given name
  class Delete < Salt::App
    def call(env)
      # TODO: Use multiple if statements, must be extract to one.
      name = env.params["name"]
      repo = Git::Repo.repository(name)
      if repo.exists?
        if repo.cloning?
          status_code = 202
          body = {
            message: "Repositoy is cloning, wait a moment.",
          }.to_json
        else
          status_code = 200
          client = Client.new
          client.delete_repository(name)
          body = "true"
        end
      else
        status_code = 404
        body = {
          message: "Not found repository: #{name}",
        }.to_json
      end

      {status_code, {"Content-Type" => "application/json"}, [body]}
    end
  end

  # Search repositories by name
  class Search < Salt::App
    include Git::Helper

    def call(env)
      Raven.breadcrumbs.record do |crumb|
        crumb.category = "api"
        crumb.timestamp = Time.now
        crumb.message = "Call #{self.class} API"
      end

      client = Client.new
      keyword = env.params["name"]
      repositories = client.search_repositories(keyword).each_with_object([] of Hash(String, String)) do |name, obj|
        obj << repository_info(name)
      end

      status_code = 200
      body = {
        total: repositories.size,
        data:  repositories,
      }

      {status_code, {"Content-Type" => "application/json"}, [body.to_json]}
    rescue e : Exception
      Hpr.capture_exception(e, "api", params: env.params.to_h.to_s)
      body = {message: e.message}.to_json
      {400, {"Content-Type" => "application/json"}, [body]}
    end
  end
end
