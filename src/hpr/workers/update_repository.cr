module Hpr
  struct UpdateRepositoryWorker
    include Sidekiq::Worker

    def perform(name : String)
      repository_path = Utils.repository_path(name)
      # Skip when repository id not exists (may be deleted).
      return unless Dir.exists?(repository_path)

      Dir.cd repository_path
      Utils.run_cmd "git config hpr.status 'busy'",
                    "git fetch origin",
                    "git push mirror",
                    "git config hpr.status 'idle'"

      update_schedule(name)
    end

    private def update_schedule(name : String)
      scheduled = Time::Span.new(0, 0, 10)
      UpdateRepositoryWorker.async.perform_in(scheduled, name)

      Dir.cd Utils.repository_path(name)
      Utils.run_cmd "git config hpr.scheduled '#{(Time.now + scheduled).to_s("%F %T %z")}'"
    end
  end
end
