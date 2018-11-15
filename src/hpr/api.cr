require "salt"
require "salt/middlewares/basic_auth"
require "salt/middlewares/logger"
require "salt/middlewares/router"
require "./git/*"
require "./apis/*"

module Hpr::API
  def self.run(port = 8848, environment = "production")
    if Hpr.config.basic_auth.enable
      user = Hpr.config.basic_auth.user
      password = Hpr.config.basic_auth.password
      Salt.use Salt::BasicAuth, user: user, password: password
    end

    app = Salt::Router.new do |r|
      r.get "/", to: Entrance.new
      r.get "/info", to: Info.new
      r.get "/repositories", to: Repositories::List.new
      r.get "/repositories/search/:name", to: Repositories::Search.new
      r.get "/repositories/:name", to: Repositories::Show.new
      r.post "/repositories", to: Repositories::Create.new
      r.put "/repositories/:name", to: Repositories::Update.new
      r.delete "/repositories/:name", to: Repositories::Delete.new
      r.not_found do |env|
        {404, {"Content-Type" => "application/json"}, [{messaeg: "Not found api"}.to_json]}
      end
    end

    Salt.use Salt::CommonLogger
    Salt.run app, environment: environment, port: port
  end
end
