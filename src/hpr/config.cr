module Hpr
  struct Config
    JSON.mapping(
      repository_path: {type: String, default: ""},
      schedule: Int64,
      api: Bool,
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
        project_issue: Bool,
        project_wiki: Bool,
        project_wall: Bool,
        project_snippet: Bool,
        project_merge_request: Bool
      )
    end
  end
end
