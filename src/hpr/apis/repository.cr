require "json"

module Hpr::API::Repository
  @@client = Client.new

  get "/repositories" do |env|
    env.response.content_type = "application/json"

    @@client.list_repositories.to_json
  end

  post "/repositories" do |env|
    env.response.content_type = "application/json"

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

    env.response.status_code = status_code
    message
  end

  put "/repositories/:name" do |env|
    env.response.content_type = "application/json"
    env.response.status_code = 200

    true.to_json
  end

  delete "/repositories/:name" do |env|
    env.response.content_type = "application/json"
    env.response.status_code = 200

    @@client.delete_repository env.params.url["name"]

    true.to_json
  end
end
