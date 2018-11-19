class Hpr::Cli
  class Create < Command
    def run(**args)
      url = args[:url]
      if url.empty?
        Terminal.error "Missing url, run `hpr create [-U url] <name>`"
        exit
      end

      name = args[:name]
      name = project_name(url) if name.empty?
      create = args[:create]
      clone = args[:clone]
      progress = args[:progress]

      if Git::Repo.repository_path?(name)
        Terminal.important "repository exists ... #{name}"
        repo = repository_info(name)
        dump_repository(repo)

        exit
      end

      start_worker
      client.create_repository(url, name, create, clone)

      sleep 1.seconds # wait for sidekiq job to run
      repo = Git::Repo.repository(name)

      loop do
        print "." if progress
        sleep 1.seconds
        if !repo.cloning? && (info = repository_info(name)) && !info["updated_at"].empty?
          puts if progress
          break
        end
      end

      Terminal.success "create repository ... done"
    rescue ex : Gitlab::Error::APIError
      Terminal.error ex.message
    end
  end
end
