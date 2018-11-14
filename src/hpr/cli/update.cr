class Hpr::Cli
  class Update < Command
    def run(**args)
      name = args[:name]
      progress = args[:progress]

      start_worker
      client.update_repository(name)
      wait_updating(name, progress)
      Terminal.success "update repository ... done"
    rescue ex : Gitlab::Error::APIError
      Terminal.error ex.message
    rescue ex : Exception
      Terminal.error "Unmatched error: #{ex.message}"
      Terminal.error "  #{ex.backtrace.join("\n  ")}"
    end
  end
end
