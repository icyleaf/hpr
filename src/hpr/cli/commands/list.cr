class Hpr::Cli
  class List < Command
    def run(**args)
      total = client.total_repositories
      Terminal.message "listing repositories (#{total}):"
      client.list_repositories(per_page: total).each do |repo|
        dump_repository(repo, File.join(@config.repository_path, repo.name))
      end
    end
  end
end
