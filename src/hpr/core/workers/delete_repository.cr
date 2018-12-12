require "file_utils"

module Hpr
  struct DeleteRepositoryWorker
    include Worker::Base

    def perform(name : String, repository_path : String)
      debug "deleting directory ... #{name}"
      if jobs = has_scheduled? name
        jobs.each &.delete
      end

      path = File.join(repository_path, name)
      FileUtils.rm_rf path
    end
  end
end
