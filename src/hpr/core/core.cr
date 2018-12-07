require "popcorn"
require "granite/adapter/sqlite"
require "raven"

module Hpr
  VERSION = "0.10.0"

  macro init(config)
    sqlite_path = Hpr.db_path({{ config.id }}.root_path)
    adapter = Granite::Adapter::Sqlite.new({name: "hpr", url: "sqlite3://#{sqlite_path}"})
    Granite::Adapters << adapter
    Model::Repository.adapter = adapter

    Hpr.init_db sqlite_path
    Hpr.init_crash_report {{ config.id }}.sentry.dns, {{ config.id }}.root_path
  end

  def self.init_db(db_path)
    unless File.exists? db_path
      Dir.mkdir_p File.dirname(db_path)
      Hpr::Model.create_tables
    end
  end

  def self.init_crash_report(dns : String, path : String, file = "logs/sentry.log")
    file = File.join(path, file)
    Dir.mkdir_p(File.dirname(file))

    Raven.configure do |c|
      c.logger = Logger.new File.open(file, "a")
      c.dsn = dns
      c.environments = %w(development production)
      c.current_environment = env
      c.release = Hpr::VERSION if production?
    end
  end

  def self.capture_exception(exception, category : String, print_output_error = false, file = __FILE__, **extra)
    # gitlab_version = "unkown"
    # begin
    #   gitlab_version = gitlab.version
    # rescue
    #   # do nothing
    # end

    Raven.capture(exception) do |event|
      event.logger ||= "hpr"
      event.tags = {
        deploy:   ENV.fetch("HPR_DEPLOY", "binary"),
        category: category,
      }
      event.extra = {
        git_version:   `git version`.strip,
        redis_version: `redis-server -v`.strip,
        # gitlab_version:  gitlab_version,
        # gitlab_endpoint: config.gitlab.endpoint.to_s,
        file: file,
      }.merge(extra)
    end

    if print_output_error
      Terminal.error "[#{exception.class}] #{exception.message}"
      Terminal.error "  #{exception.backtrace.join("\n  ")}"
    end
  end

  def self.verbose?
    Popcorn.to_bool ENV.fetch("HPR_VERBOSE", "false")
  end

  def self.env
    ENV.fetch("HPR_ENV", "development")
  end

  def self.production?
    env == "production"
  end

  def self.db_path(root_path)
    File.expand_path File.join(root_path, "data", "hpr-data.db")
  end
end
