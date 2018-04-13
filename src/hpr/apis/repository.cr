module Hpr::API::Repository
  @@client = Client.new

  # List all repositories
  get "/repositories" do |env|
    env.response.content_type = "application/json"
    names = @@client.list_repositories
    repositories = names.each_with_object([] of Hash(String, String)) do |name, obj|
      obj << Utils.repository_info(name) if Utils.repository_path?(name)
    end

    {
      total: repositories.size,
      data:  repositories,
    }.to_json
  end

  # Get a repository by given name
  get "/repositories/:name" do |env|
    name = env.params.url["name"]
    if Utils.repository_path?(name)
      if Utils.repository_cloning?(name)
        status_code = 202
        message = {
          message: "Repositoy is cloning, wait a moment."
        }
      else
        status_code = 200
        message = Utils.repository_info(name)
      end
    else
      status_code = 200
      message = {
        message: "Not found repository."
      }
    end

    env.response.content_type = "application/json"
    env.response.status_code = status_code
    message.to_json
  end

  # Create new repository
  post "/repositories" do |env|
    begin
      url = env.params.body["url"]
      name = env.params.body["name"]?
      @@client.create_repository(
        url, name,
        env.params.body.fetch("mirror_only", "false") == "true"
      )
      message = true
      status_code = 201
    rescue e : Exception
      message = {
        message: e.message,
      }
      status_code = 400
    end

    env.response.content_type = "application/json"
    env.response.status_code = status_code
    message.to_json
  end

  # Update a repository by given name
  put "/repositories/:name" do |env|
    @@client.update_repository(env.params.url["name"])

    env.response.content_type = "application/json"
    env.response.status_code = 200
    true.to_json
  end

  # Remove a repository by given name
  delete "/repositories/:name" do |env|
    @@client.delete_repository env.params.url["name"]

    env.response.content_type = "application/json"
    env.response.status_code = 200
    true.to_json
  end
end
