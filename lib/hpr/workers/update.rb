# frozen_string_literal: true

module Hpr
  # Update git repository worker
  class UpdateWorker
    include Sidekiq::Worker
    include Hpr::Worker

    def perform(name)
      return unless ensure_git_repository_exist(name)

      repository = Repository.find_by(name: name)

      unless repository
        logger.error "not found repository #{name}, exit"
        return
      end

      update_repository name, repository
      schedule_update_job name, repository
    end

    def update_repository(name, repository)
      git = ::Git.bare git_repository_path(name)
      logger.debug "updating from origin ... #{name}"
      repository.update! status: :fetching
      git.fetch 'origin'

      logger.debug "pushing to gitlab ... #{name}"
      repository.update! status: :pushing
      git.push 'hpr', '', mirror: true
    end
  end
end
