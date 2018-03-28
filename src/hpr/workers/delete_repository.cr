module Hpr
  struct DeleteRepositoryWorker
    include Sidekiq::Worker

    def perform(name : String)
      FileUtils.rm_rf Utils.repository_path(name)
    end
  end
end
