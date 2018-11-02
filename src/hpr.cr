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

  def config(path : String, index : Int32 = 0)
    @@config = Config.load(path, index)
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

  # private def load_config(path : String? = nil, index : Int32 = -1)
  #   Hpr::Config.configure do |config|
  #     insert_config_path(config, path, index) if path
  #     repository_path = File.join("repositories", config.get("gitlab.group_name").to_s)
  #     config.set_default "repository_path", File.expand_path(repository_path)
  #   end
  # end

  # private def insert_config_path(config, path, index)
  #   if File.file?(path)
  #     extname = File.extname(path)
  #     filename = File.basename(path, extname)

  #     config.config_name = filename
  #     config.config_type = extname[1..-1]

  #     path = File.dirname(path)
  #   end

  #   config.config_paths.insert(index, path)
  #   config.load!
  # end

  private def hpr_logger_formatter
    Logger::Formatter.new do |severity, datetime, progname, message, io|
      io << datetime << "   " << severity << "   " << message
    end
  end
end
