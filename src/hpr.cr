require "./hpr/*"
require "gitlab"

module Hpr
  CONFIG_FILE = "config/hpr.json"
  @@config : Config = Config.load(CONFIG_FILE)
  def self.config
    @@config
  end

  @@gitlab = Gitlab::Client.new(@@config.gitlab.endpoint, @@config.gitlab.private_token)
  def self.gitlab
    @@gitlab
  end

  @@log_instance = Logger.new(STDOUT)
  def self.log
    @@log_instance
  end
end
