require "salt"
require "salt/middlewares/basic_auth"
require "salt/middlewares/router"
require "./apis/*"

module Hpr::API
  CLIENT = Client.new

  def self.run(port = 8848, environment = "production")
    # Salt.use Salt::CommonLogger if environment == "production"

    if Hpr.config.basic_auth.enable
      user = Hpr.config.basic_auth.user
      password = Hpr.config.basic_auth.password
      Salt.use Salt::BasicAuth, user: user, password: password
    end

    app = Salt::Router.new do |r|
      r.get "/", to: Entrance.new
      r.get "/info", to: Info.new
      # r.get "/repositories", to: Repositories::List.new
      # r.get "/repositories/:id", to: Repositories::Show.new
      # r.put "/repositories/:id", to: Repositories::Update.new
      # r.delete "/repositories/:id", to: Repositories::Delete.new
    end

    Hpr.logger.info "API Server now listening at localhost:#{port}#{Hpr.config.basic_auth.enable ? " (basic auth)" : ""}, press Ctrl-C to stop"

    Salt.run app, environment: environment, port: port
  end
end
