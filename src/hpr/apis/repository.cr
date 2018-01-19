module Hpr::API::Repository
  @@client = Client.new

  get "/repositories" do |env|
    env.response.content_type = "application/json"
    names = @@client.list_repositories
    repositories = names.each_with_object([] of Hash(String, String)) do |name, obj|
      obj << Utils.repository_info(name) if Utils.repository_path?(name)
    end

    {
      total: repositories.size,
      data: repositories
    }.to_json
  end

  get "/repositories/:name" do |env|
    name = env.params.url["name"]
    if Utils.repository_path?(name)
      status_code = 200
      message = Utils.repository_info(name)
    else
      status_code = 408
      message = {
        message: "Not found repository."
      }
    end

    env.response.content_type = "application/json"
    env.response.status_code = status_code
    message.to_json
  end

  post "/repositories" do |env|
    begin
      @@client.create_repository(
        env.params.body["url"],
        env.params.body["name"],
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

  put "/repositories/:name" do |env|
    @@client.update_repository(env.params.url["name"])

    env.response.content_type = "application/json"
    env.response.status_code = 200
    true.to_json
  end

  delete "/repositories/:name" do |env|
    @@client.delete_repository env.params.url["name"]

    env.response.content_type = "application/json"
    env.response.status_code = 200
    true.to_json
  end
end
