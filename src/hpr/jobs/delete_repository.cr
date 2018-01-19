module Hpr
  struct DeleteRepositoryJob < Faktory::Job
    arg name : String

    def perform
      FileUtils.rm_rf Utils.repository_path(name)
    end
  end
end
