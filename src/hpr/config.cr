module Hpr
  struct Config
    JSON.mapping(
      repository_path: {type: String, default: ""},
      schedule: Int64,
      basic_auth: BasicAuthStruct,
      gitlab: GitlabStruct
    )

    def self.load(file : String)
      cls = self.from_json File.open(file)
      cls.repository_path = File.expand_path "repositories"
      cls
    end

    class GitlabStruct
      JSON.mapping(
        endpoint: String,
        private_token: String,
        group_name: String,
        project_public: Bool,
        project_issue: Bool,
        project_wiki: Bool,
        project_snippet: Bool,
        project_merge_request: Bool
      )
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
