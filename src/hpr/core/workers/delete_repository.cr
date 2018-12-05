require "file_utils"

module Hpr
  struct DeleteRepositoryWorker
    include Worker::Base

    def perform(name : String, repository_path : String)
      info "deleting directory ... #{name}"
      if job = has_scheduled? name
        job.delete
      end

      path = File.join(repository_path, name)
      FileUtils.rm_rf path
    end
  end
end
