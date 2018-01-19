require "./hpr/*"

module Hpr

  @@log_instance = Logger.new(STDOUT)

  def self.log
    @@log_instance
  end
end
