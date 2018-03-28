require "kemal"
require "kemal-basic-auth"
require "./apis/*"

module Hpr::API
  CLIENT = Client.new

  def self.run(port = 8848)
    Hpr.logger.info "API Server now listening at localhost:8848, press Ctrl-C to stop"

    if Hpr.config.basic_auth.enable
      basic_auth Hpr.config.basic_auth.user, Hpr.config.basic_auth.password
    end

    Kemal.config.logging = false
    Kemal.config.env = "production"
    Kemal.run port
  end

  include Entrance
  include Repository
end
