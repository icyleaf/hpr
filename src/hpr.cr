require "./hpr/*"
require "gitlab"

module Hpr
  extend self

  @@config : Config?
  @@gitlab : Gitlab::Client?
  @@logger : Logger?

  def config
    @@config ||= Config.load
    @@config.not_nil!
  end

  def config(file : String)
    @@config = Config.load(file)
    @@config.not_nil!
  end

  def gitlab
    @@gitlab ||= Gitlab.client(config.gitlab.endpoint.to_s, config.gitlab.private_token)
    @@gitlab.not_nil!
  end

  def logger
    @@logger ||= Logger.new(STDOUT, Logger::DEBUG, hpr_logger_formatter)
    @@logger.not_nil!
  end

  private def hpr_logger_formatter
    Logger::Formatter.new do |severity, datetime, progname, message, io|
      io << datetime << "   " << severity << "   " << message
    end
  end
end
