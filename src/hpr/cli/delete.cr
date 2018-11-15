class Hpr::Cli
  class Delete < Command
    def run(**args)
      determine_config!

      name = args[:name]
      progress = args[:progress]

      start_worker
      client.delete_repository(name)
      wait_updating(name, progress)

      Terminal.success "deleting repository ... done"
    rescue e : Gitlab::Error::APIError
      Terminal.error e.message
    rescue e : Exception
      Terminal.error "Unmatched error: #{e.message}"
      Terminal.error "  #{e.backtrace.join("\n  ")}"
      Raven.capture(e)
    end
  end
end
