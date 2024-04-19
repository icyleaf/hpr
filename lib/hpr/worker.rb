# frozen_string_literal: true

require 'sidekiq/api'

module Hpr
  module Worker
    def schedule_update_job(name, repository)
      if scheduled?(name) # May be the current worker is still in schedule list.
        logger.debug "scheduled list exists job ... #{name}"
        return
      end

      start_time = Time.at(Time.now.to_i + Configuration.schedule_in_seconds)
      logger.debug "scheduling next update at #{start_time} ... #{name}"

      repository.update status: 'idle', scheduled_at: start_time
      UpdateWorker.perform_at start_time, name
    end

    def scheduled?(name)
      scheduled = Sidekiq::ScheduledSet.new
      rs = scheduled.select { |s| JSON.parse(s.value)['args'].first == name }
      rs unless rs.empty?
    end

    def ensure_git_repository_not_exist(name)
      if git_repository_exist?(name)
        logger.error "Repository directory #{name} was exists, exit"
        return false
      end

      true
    end

    def ensure_git_repository_exist(name)
      unless git_repository_exist?(name)
        logger.error "Repository directory #{name} was not exists, exit"
        return false
      end

      true
    end

    def git_repository_exist?(name)
      path = git_repository_path(name)
      path if File.directory? path
    end

    def git_repository_path(name)
      File.join repository_path, name
    end

    def repository_path
      @repository_path ||= Configuration.repository_path
    end
  end
end

require 'hpr/workers/update'
require 'hpr/workers/clone'
require 'hpr/workers/destroy'
