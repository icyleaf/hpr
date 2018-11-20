require "totem"

module Hpr
  struct Config
    include Totem::ConfigBuilder

    CONFIG_NAME = "hpr"
    CONFIG_TYPE = "json"
    CONFIG_PATH = File.expand_path("config")

    build do
      config_name CONFIG_NAME
      config_type CONFIG_TYPE
      config_paths [CONFIG_PATH]
    end

    property hpr_path : String
    property repository_path : String
    setter schedule_in : String | Int32 | Int64
    property basic_auth : BasicAuth
    property gitlab : Gitlab
    property sentry : Sentry

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

    module LoadHelper
      def load
        Hpr::Config.configure do |config|
          default_config(config)
        end
      end

      def load(file : String)
        file = File.join(file, "#{CONFIG_NAME}.#{CONFIG_TYPE}") if File.directory?(file)
        Hpr::Config.configure(file, 0) do |config|
          default_config(config, file)
        end
      end

      private def default_config(config, path = CONFIG_PATH)
        config.set_default "hpr_path", root_path(path)
        config.set_default "repository_path", repository_path(config)
        config
      end

      private def root_path(path)
        path = File.dirname(path) if File.file?(path)
        File.expand_path("../", path)
      end

      private def repository_path(config)
        File.join(config["hpr_path"].to_s, "repositories", config.get("gitlab.group_name").to_s)
      end
    end

    extend LoadHelper

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

    struct Sentry
      include JSON::Serializable

      property report : Bool
      property dns : String
    end
  end
end
