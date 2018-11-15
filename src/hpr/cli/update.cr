class Hpr::Cli
  class Update < Command
    def run(**args)
      name = args[:name]
      progress = args[:progress]

      start_worker
      client.update_repository(name)
      wait_updating(name, progress)
      Terminal.success "update repository ... done"
    rescue e : Gitlab::Error::APIError
      Terminal.error e.message
    rescue e : Exception
      Terminal.error "Unmatched error: #{e.message}"
      Terminal.error "  #{e.backtrace.join("\n  ")}"
      Raven.capture(e)
    end
  end
end
