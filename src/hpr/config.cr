module Hpr
  struct Config
    JSON.mapping(
      repository_path: {type: String, default: ""},
      schedule_in: {type: String | Int32 | Int64, getter: false},
      basic_auth: BasicAuthStruct,
      gitlab: GitlabStruct
    )

    def self.load(file : String)
      cls = self.from_json File.open(file)
      cls.repository_path = File.expand_path File.join("repositories", cls.gitlab.group_name)
      cls
    end

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

    class GitlabStruct
      JSON.mapping(
        ssh_port: Int32,
        endpoint: {type: String, getter: false},
        private_token: String,
        group_name: String,
        project_public: Bool,
        project_issue: Bool,
        project_wiki: Bool,
        project_snippet: Bool,
        project_merge_request: Bool
      )

      def endpoint : URI
        URI.parse @endpoint
      end
    end

    class BasicAuthStruct
      JSON.mapping(
        enable: Bool,
        user: {type: String, default: ""},
        password: {type: String, default: ""},
      )
    end
  end
end
