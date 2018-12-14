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
      config_paths ["/etc/", "~/.config/hpr/", CONFIG_PATH]
      debugging Hpr.verbose?
    end

    property root_path : String
    property repository_path : String
    setter schedule_in : String | Int32 | Int64
    property basic_auth : BasicAuth
    property gitlab : Gitlab
    property sentry : Sentry

    def schedule_in : Time::Span | Time::MonthSpan
      schedule_in = @schedule_in.to_s
      unless schedule_in.includes?(".")
        return Time::Span.new(0, @schedule_in.to_i, 0)
      end

      value, unit = schedule_in.split(".", 2)
      value = value.to_i
      case unit
      when "hour", "hours"
        Time::Span.new(value, 0, 0)
      when "day", "days"
        Time::Span.new(value, 0, 0, 0)
      when "week", "weeks"
        Time::Span.new(value * 7, 0, 0, 0)
      when "month", "months"
        Time::MonthSpan.new(value)
      when "year", "years"
        Time::MonthSpan.new(value * 12)
      else
        Time::Span.new(0, value, 0) # convert to minutes
      end
    end

    def schedule_at : Time
      schedule_in.from_now
    end

    def schedule_in_seconds : Int64
      case value = schedule_in
      when Time::Span
        value.to_i
      else
        value.value.to_i64 * 30 * 24 * 60 * 60
      end
    end

    module LoadHelper
      def load
        Hpr::Config.configure do |config|
          default_config config
        end
      end

      def load(config_path : String)
        file = File.expand_path(File.join(config_path, "#{CONFIG_NAME}.#{CONFIG_TYPE}"))
        Hpr::Config.configure(file, 0) do |config|
          default_config config, file
        end
      end

      private def default_config(config, path = CONFIG_PATH)
        config.set_default "root_path", root_path(path)
        config.set_default "repository_path", repository_path(config)
        config
      end

      private def root_path(path)
        path = File.dirname(path) if File.file?(path)
        File.expand_path "../", path
      end

      private def repository_path(config)
        File.join config["root_path"].to_s, "repositories", config.get("gitlab.group_name").to_s
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
      property endpoint : String
      property private_token : String
      property group_name : String

      property project_public : Bool
      property project_issue : Bool
      property project_wiki : Bool
      property project_snippet : Bool
      property project_merge_request : Bool
    end

    struct Sentry
      include JSON::Serializable

      property report : Bool
      property dns : String
    end

    extend LoadHelper
  end
end
