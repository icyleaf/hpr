class Hpr::Cli
  class Upgrade < Command
    def run(**args)
      start_worker

      Dir.glob(File.join(@config.repository_path, "*")) do |path|
        name = File.basename(path)
        repo = Git.new(path)

        print "#{name} ... "
        if model = client.has_repository?(name)
          if model.scheduled_at
            puts "[PASS]".colorize(:yellow)
          else
            update_repository(name)
            puts "[UPGRADED]".colorize(:green)
          end
        else
          url = repo.remote("origin").pull_url
          mirror_url = repo.remote("hpr").push_url
          Model::Repository.create name: name, url: url, mirror_url: mirror_url
          update_repository(name)
          puts "[UPGRADED]".colorize(:green)
        end
      end
    end

    private def update_repository(name)
      client.update_repository(name)
      wait_updating(name, false)
    end
  end
end
