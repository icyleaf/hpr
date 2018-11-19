require "./hpr/*"
require "gitlab"
require "raven"

module Hpr
  extend self

  @@config : Config?
  @@gitlab : Gitlab::Client?
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

  def capture_exception(exception, category : String, print_output_error = false, file = __FILE__, **extra)
    if print_output_error
      Terminal.error "[#{exception.class}] #{exception.message}"
      Terminal.error "  #{exception.backtrace.join("\n  ")}"
    end

    gitlab_version = "unkown"
    begin
      gitlab_version = gitlab.version
    rescue
      # do nothing
    end

    Raven.capture(exception, tags: {
      deploy:   ENV.fetch("HPR_DEPLOY", "binary"),
      category: category,
    }, extra: {
      git_version: `git version`.strip,
      redis_version: `redis-server -v`.strip,
      gitlab_version:  gitlab_version,
      gitlab_endpoint: config.gitlab.endpoint.to_s,
      file:            file,
    }.merge(extra))
  end
end
