# frozen_string_literal: true

module Hpr
  # Clone git repository worker
  class CloneWorker
    include Sidekiq::Job
    include Hpr::Worker

    sidekiq_options retry: false

    def perform(name, url, mirror_url, gitlab_project_id)
      return unless ensure_git_repository_not_exist(name)

      sleep 10000000

      @name = name
      @url = url
      @mirror_url = mirror_url
      @gitlab_project_id = gitlab_project_id
      @repository = Repository.find_or_create_by name: name, url: url, mirror_url: mirror_url,
                                                 gitlab_project_id: gitlab_project_id,
                                                 status: :cloning

      clone
      configure
      pushing
      schedule_update_job name, @repository
    rescue => e
      Sentry.capture_exception e
      clean_clone_artifacts
      raise e
    end

    private

    def clone
      logger.debug "cloning #{@url} ... #{@name}"
      git_clone_config = 'core.sshCommand=ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no'
      @git = ::Git.clone @url, @name, path: repository_path, mirror: true, log: nil, config: git_clone_config
    end

    def configure
      logger.debug "writing remote config to git ... #{@name}"

      @git.add_remote 'hpr', @mirror_url
      @git.config 'remote.hpr.push', '+refs/heads/*:refs/heads/*', '+refs/tags/*:refs/tags/*'
      @git.config 'remote.hpr.mirror', 'true'
      @git.config 'credential.helper', 'store'
    end

    def pushing
      logger.debug "pushing to gitlab ... #{@name}"

      @repository.update! status: :pushing
      @git.push 'hpr', '', mirror: true
    end

    def clean_clone_artifacts
      clean_database_record
      clean_gitlab_project
      clean_git_files
    end

    def clean_database_record
      logger.debug 'Destory database record ...'
      @repository.destroy
    end

    def clean_gitlab_project
      logger.debug 'Clean gitlab project ...'
      gitlab.delete_project @gitlab_project_id
    rescue Gitlab::Error::NotFound
      # do nothing
    end

    def clean_git_files
      return unless path = git_repository_exist?(@name)

      logger.debug "Cleaning #{path} ..."
      FileUtils.rm_rf path
    end

    def gitlab
      @gitlab ||= Gitlab.client(
        endpoint: Hpr::Configuration.gitlab.endpoint,
        private_token: Hpr::Configuration.gitlab.private_token
      )
    end
  end
end
