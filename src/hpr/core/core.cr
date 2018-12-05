require "popcorn"
require "raven"

module Hpr
  def self.init_crash_report(dns : String, path : String, file = "logs/sentry.log")
    file = File.join(path, file)
    Dir.mkdir_p(File.dirname(file))

    hpr_env = ENV.fetch("HPR_ENV", "development")
    Raven.configure do |c|
      c.logger = Logger.new(File.open(file, "a"))
      c.dsn = dns
      c.environments = %w(development production)
      c.current_environment = hpr_env
      c.release = Hpr::VERSION if hpr_env == "production"
    end
  end

  def self.verbose?
    Popcorn.to_bool ENV.fetch("HPR_VERBOSE", "false")
  end

  def self.db_path
    File.expand_path File.join("data", "hpr-data.db")
  end
end
