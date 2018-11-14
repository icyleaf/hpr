module Hpr
  struct DeleteRepositoryWorker
    include Worker::Base

    def perform(name : String)
      info "deleting directory ... #{name}"
      if path = Git::Repo.repository_path?(name)
        FileUtils.rm_rf path

        # TODO: delete schedule if exists
      end
    end
  end
end
