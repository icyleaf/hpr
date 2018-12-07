class Hpr::Cli
  class Search < Command
    def run(**args)
      name = args[:name]
      Terminal.message "searching repositories ... #{name}"
      repositories = client.search_repositories(name)

      Terminal.message "found repositories (#{repositories.size}):"
      repositories.each do |repo|
        dump_repository(repo, File.join(@config.repository_path, repo.name))
      end
    end
  end
end
