require "./hpr/core/config"
require "granite/adapter/sqlite"
require "raven"

ENV["HPR_VERBOSE"] = "true"

config_path = "~/docker/volumes/hpr/hpr/config" # "/app/config"
config = Hpr::Config.load(config_path)

Hpr.init config

require "./hpr/web/server"

spawn do
  Hpr::Worker.run(config)
end

Hpr::Server.run(config)
