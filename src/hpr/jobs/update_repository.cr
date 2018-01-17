module Hpr
  struct UpdateRepositoryJob < Faktory::Job
    arg name : String
    arg config : Config

    def perform
      repository_path = File.join config.repository_path, name
      Dir.cd repository_path

      Utils.run_cmd "git fetch origin",
                    "git push downstream"

      update_schedule!
    end

    private def update_schedule!
      UpdateRepositoryJob.perform_async(name, config) do |options|
        options.at Time.now + Time::Span.new(0, 0, config.schedule)
      end
    end
  end
end
