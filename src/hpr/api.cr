require "kemal"
require "kemal-basic-auth"
require "./apis/*"

module Hpr::API
  CLIENT = Client.new

  def self.run(port = 8848)
    Hpr.log.info "API Server now listening at localhost:8848, press Ctrl-C to stop"

    basic_auth Hpr.config.auth.user, Hpr.config.auth.password if Hpr.config.auth.enable

    Kemal.config.logging = false
    Kemal.config.env = "production"
    Kemal.run port
  end

  include Entrance
  include Repository
end
