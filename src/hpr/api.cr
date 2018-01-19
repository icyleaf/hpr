require "kemal"
require "kemal-basic-auth"
require "./apis/*"

module Hpr::API
  def self.run(port = 8848)
    Hpr.log.info "API Server now listening at localhost:8848, press Ctrl-C to stop"

    basic_auth ENV["HPR_AUTH_USERNAME"], ENV["HPR_AUTH_PASSWORD"] if ENV.has_key?("HPR_AUTH") && ENV["HPR_AUTH"] == "true"

    # Kemal.config.logging = false
    Kemal.run port
  end

  include Repository
  include Error
end
