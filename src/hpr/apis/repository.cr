require "json"

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
      message = Utils.repository_info(name).to_json
    else
      message = {
        message: "Not found repository: #{name}."
      }.to_json
      status_code = 404
    end

    env.response.content_type = "application/json"
    env.response.status_code = status_code
    message
  end

  post "/repositories" do |env|
    begin
      jid = @@client.create_repository(env.params.body["url"], env.params.body["name"])
      message = true.to_json
      status_code = 201
    rescue e : Exception
      message = {
        message: e.message,
      }.to_json
      status_code = 400
    end

    env.response.content_type = "application/json"
    env.response.status_code = status_code
    message
  end

  put "/repositories/:name" do |env|
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
