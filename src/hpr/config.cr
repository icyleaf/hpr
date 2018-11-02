require "totem"

module Hpr
  struct Config
    include Totem::ConfigBuilder

    def self.load(path : String? = nil, index : Int = -1)
      Hpr::Config.configure do |config|
        config = insert_config_path(config, path, index) if path
        repository_path = File.join("repositories", config.get("gitlab.group_name").to_s)
        config.set_default "repository_path", File.expand_path(repository_path)
      end
    end

    private def self.insert_config_path(config, path, index)
      if File.file?(path)
        extname = File.extname(path)
        filename = File.basename(path, extname)

        config.config_name = filename
        config.config_type = extname[1..-1]

        path = File.dirname(path)
      end

      config.config_paths.insert(index, path)
      config.load!
      config
    end

    build do
      config_name "hpr"
      config_type "json"
      config_paths ["/app/config", "./config"]
      # debugging true
    end

    property repository_path : String = ""
    setter schedule_in : String|Int32|Int64
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
