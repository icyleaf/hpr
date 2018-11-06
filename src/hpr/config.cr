require "totem"

module Hpr
  struct Config
    include Totem::ConfigBuilder

    def self.load(path : String? = nil, index : Int = -1)
      Hpr::Config.configure do |config|
        config.set_default "hpr_path", hpr_path(config, path, index)
        config.set_default "repository_path", repository_path(config)
      end
    end

    private def self.hpr_path(config, path : String? = nil, index : Int = -1)
      path ? load_config_path(config, path, index) : File.expand_path(".")
    end

    private def self.load_config_path(config, path, index)
      raise "Pass directory path only" if File.file?(path)

      config.config_paths.insert index, File.join(path, "config")
      config.load!

      File.expand_path(path)
    end

    private def self.repository_path(config)
      File.join(config["hpr_path"].to_s, "repositories", config.get("gitlab.group_name").to_s)
    end

    build do
      config_name "hpr"
      config_type "json"
      config_paths ["config"]
    end

    property hpr_path : String
    property repository_path : String
    setter schedule_in : String | Int32 | Int64
    property basic_auth : BasicAuth
    property gitlab : Gitlab

    def schedule_in
      unless @schedule_in.to_s.includes?(".")
        return Time::Span.new(0, @schedule_in.to_i, 0)
      end

      value, unit = @schedule_in.to_s.split(".", 2)
      case unit
      when "hour", "hours"
        Time::Span.new(value.to_i, 0, 0)
      when "day", "days"
        Time::Span.new(value.to_i, 0, 0, 0)
      when "week", "weeks"
        Time::Span.new(value.to_i * 7, 0, 0, 0)
      when "month", "months"
        Time::MonthSpan.new(value.to_i)
      when "year", "years"
        Time::MonthSpan.new(value.to_i * 12)
      else
        Time::Span.new(0, value.to_i, 0) # convert to minutes
      end
    end

    struct BasicAuth
      include JSON::Serializable

      property enable : Bool
      property user : String = ""
      property password : String = ""
    end

    struct Gitlab
      include JSON::Serializable

      property ssh_port : Int32
      setter endpoint : String
      property private_token : String
      property group_name : String

      property project_public : Bool
      property project_issue : Bool
      property project_wiki : Bool
      property project_snippet : Bool
      property project_merge_request : Bool

      def endpoint : URI
        URI.parse @endpoint
      end
    end
  end
end
