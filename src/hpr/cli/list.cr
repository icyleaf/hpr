class Hpr::Cli
  class List < Command
    def run(**args)
      repositories = client.list_repositories.each_with_object([] of Hash(String, String)) do |name, obj|
        obj << repository_info(name)
      end

      if repositories.empty?
        Terminal.important "Not found repositories"
        return
      end

      Terminal.message "listing repositories (#{repositories.size}):"
      repositories.each do |repo|
        dump_repository(repo)
      end
    rescue e : Gitlab::Error::APIError
      Terminal.error e.message
    rescue e : Exception
      Terminal.error "Unmatched error: #{e.message}"
      Terminal.error "  #{e.backtrace.join("\n  ")}"
      Hpr.capture_exception(e, "cli")
    end
  end
end
