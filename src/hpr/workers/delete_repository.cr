module Hpr
  struct DeleteRepositoryWorker
    include Worker::Base

    def perform(name : String)
      info "deleting directory ... #{name}"
      if job = has_scheduled?(name)
        job.delete
      end

      return unless path = Git::Repo.repository_path?(name)
      FileUtils.rm_rf path
    end
  end
end
