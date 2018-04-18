module Hpr
  struct DeleteRepositoryWorker
    include Sidekiq::Worker

    def perform(name : String)
      Hpr.logger.info "deleting directory ... #{name}"
      FileUtils.rm_rf Utils.repository_path(name)
    end
  end
end
