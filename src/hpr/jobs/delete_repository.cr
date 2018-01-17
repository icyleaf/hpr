module Hpr
  struct DeleteRepositoryJob < Faktory::Job
    arg name : String
    arg config : Config

    def perform
      FileUtils.rm_rf File.join(config.repository_path, name)
    end
  end
end
