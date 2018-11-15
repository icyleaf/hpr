require "./hpr/*"
require "gitlab"
require "raven"

module Hpr
  extend self

  @@config : Config?
  @@gitlab : Gitlab::Client?
  @@logger : Logger?
  @@debugging = false

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

  def debugging
    @@debugging
  end

  def debugging(value : Bool)
    @@debugging = value
  end

  def crash_report!(path = "logs")
    return unless config.sentry.report

    logs_path = File.join(Hpr.config.hpr_path, path)
    FileUtils.mkdir_p(logs_path)

    file = File.join(logs_path, "sentry.log")
    io = File.open(file, "a")

    Raven.configure do |c|
      c.logger = Logger.new(io)
      c.dsn = config.sentry.dns
      c.environments = %w(development production)
      c.current_environment = ENV.fetch("HPR_ENV", "development")
    end

    Raven.user_context(
      email: "icyleaf.cn@gmail.com" # '127.0.0.1'
    )
  end

  private def hpr_logger_formatter
    Logger::Formatter.new do |severity, datetime, progname, message, io|
      io << datetime << "   " << severity << "   " << message
    end
  end
end

Hpr.crash_report!
