require "./hpr/*"
require "gitlab"

module Hpr
  extend self

  CONFIG_FILE = "config/hpr.json"

  @@config : Config | Nil

  def config
    @@config ||= Config.load(CONFIG_FILE)
    @@config.not_nil!
  end

  @@gitlab : Gitlab::Client | Nil

  def gitlab
    @@gitlab ||= Gitlab.client(config.gitlab.endpoint.to_s, config.gitlab.private_token)
    @@gitlab.not_nil!
  end

  @@logger : Logger | Nil

  def logger
    @@logger ||= Logger.new(STDOUT)
    @@logger.not_nil!.level = Logger::DEBUG
    @@logger.not_nil!.progname = "hpr"
    @@logger.not_nil!
  end
end
