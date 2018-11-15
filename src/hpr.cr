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

    FileUtils.mkdir_p(path)
    file = File.join(path, "sentry.log")
    io = File.open(file, "a")

    hpr_env = ENV.fetch("HPR_ENV", "development")
    Raven.configure do |c|
      c.logger = Logger.new(io)
      c.dsn = config.sentry.dns
      c.environments = %w(development production)
      c.current_environment = ENV.fetch("HPR_ENV", "development")
      c.release = Hpr::VERSION if hpr_env == "production"
    end

    # Raven.user_context(
    #   email: "icyleaf.cn@gmail.com"
    # )
  end

  def capture_exception(exception, category : String, file = __FILE__, **extra)
    gitlab_version = "unkown"
    begin
      gitlab_version = Hpr.gitlab.version
    rescue
      # do nothing
    end

    Raven.capture(exception, tags: {
      deploy:   ENV.fetch("HPR_DEPLOY", "binary"),
      category: category,
    }, extra: {
      gitlab_version:  gitlab_version,
      gitlab_endpoint: Hpr.config.gitlab.endpoint.to_s,
      file:            file,
    }.merge(extra))
  end

  private def hpr_logger_formatter
    Logger::Formatter.new do |severity, datetime, progname, message, io|
      io << datetime << "   " << severity << "   " << message
    end
  end
end
