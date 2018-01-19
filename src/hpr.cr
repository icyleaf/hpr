require "./hpr/*"
require "gitlab"

module Hpr
  CONFIG_FILE = "config/hpr.json"
  @@config : Config | Nil
  def self.config
    @@config ||= Config.load(CONFIG_FILE)
    @@config.not_nil!
  end

  @@gitlab : Gitlab::Client | Nil
  def self.gitlab
    @@gitlab ||= Gitlab.client(config.gitlab.endpoint, config.gitlab.private_token)
    @@gitlab.not_nil!
  end

  @@log_instance = Logger.new(STDOUT)
  def self.log
    @@log_instance
  end
end
