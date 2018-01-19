module Hpr
  struct UpdateRepositoryJob < Faktory::Job
    arg name : String

    def perform
      Dir.cd Utils.repository_path(name)

      Utils.run_cmd "git fetch origin",
                    "git push downstream"

      # update_schedule!
    end

    # private def update_schedule!
    #   UpdateRepositoryJob.perform_async(name) do |options|
    #     options.at Time.now + Time::Span.new(0, 0, Hpr.config.schedule)
    #   end
    # end
  end
end
