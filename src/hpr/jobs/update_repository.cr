module Hpr
  struct UpdateRepositoryJob < Faktory::Job
    arg name : String

    def perform
      repository_path = Utils.repository_path(name)
      # Skip when repository id not exists (may be deleted).
      return unless Dir.exists?(repository_path)

      Dir.cd repository_path
      Utils.run_cmd "git config hpr.status 'busy'",
                    "git fetch origin",
                    "git push mirror",
                    "git config hpr.status 'idle'"

      update_schedule
    end

    private def update_schedule
      scheduled = Time.now + Time::Span.new(0, 0, Hpr.config.schedule)
      UpdateRepositoryJob.perform_async(name) do |options|
        options.at scheduled
      end

      Dir.cd Utils.repository_path(name)
      Utils.run_cmd "git config hpr.scheduled '#{scheduled.to_s("%F %T %z")}'"
    end
  end
end
