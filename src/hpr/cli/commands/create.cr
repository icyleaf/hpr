class Hpr::Cli
  class Create < Command
    def run(**args)
      url = args[:url]
      if url.empty?
        return Terminal.error "Missing url, run `hpr create [-U url] <name>`"
      end

      name = args[:name]
      name = Git::URLParser.new(url).mirror_name if name.empty?
      create = args[:create]
      clone = args[:clone]
      progress = args[:progress]

      repo_path = File.join(@config.repository_path, name)
      if (model = client.has_repository?(name)) && Dir.exists?(repo_path)
        Terminal.important "repository exists ... #{name}"
        return dump_repository(model, repo_path)
      end

      start_worker
      client.create_repository(url, name, create, clone)

      sleep 1.seconds # wait for sidekiq job to run
      repo = Git.new(repo_path)

      loop do
        print "." if progress
        sleep 1.seconds
        model = client.repository(name)
        if model.status == "idle"
          puts if progress
          break
        end
      end

      Terminal.success "create repository ... done"
    rescue ex : Gitlab::Error::APIError | Hpr::RepositoryExistsError
      Terminal.error ex.message
    end
  end
end
