require "./hpr/*"
require "gitlab"

module Hpr
  extend self

  CONFI_PATH = "config/hpr.json"

  @@config : Config | Nil

  def config
    @@config ||= Config.load(CONFI_PATH)
    @@config.not_nil!
  end

  def reload_config(path : String)
    @@config = Config.load(path)
    @@config.not_nil!
  end

  @@gitlab : Gitlab::Client | Nil

  def gitlab
    return @@gitlab.not_nil! unless @@gitlab.nil?

    @@gitlab ||= Gitlab.client(config.gitlab.endpoint.to_s, config.gitlab.private_token)
    @@gitlab.not_nil!
  end

  @@logger : Logger | Nil

  def logger
    return @@logger.not_nil! unless @@logger.nil?

    @@logger ||= Logger.new(STDOUT)
    @@logger.not_nil!.level = Logger::DEBUG
    @@logger.not_nil!.formatter = Logger::Formatter.new do |severity, datetime, progname, message, io|
      io << datetime << "   " << severity << "   " << message
    end
    @@logger.not_nil!
  end
end
