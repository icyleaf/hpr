# frozen_string_literal: true

module Hpr
  # Destroy git repository worker
  class DestroyWorker
    include Sidekiq::Job
    include Hpr::Worker

    def perform(name)
      @name = name

      delete_busy_jobs
      delete_retries_jobs
      delete_scheduled_jobs
      delete_git_files
    rescue => e
      Sentry.capture_exception(e)
      raise e
    end

    def delete_scheduled_jobs
      return unless jobs = scheduled?(@name)

      jobs.map(&:delete)
    end

    def delete_retries_jobs
      retries = Sidekiq::RetrySet.new
      retries.select { |r| r.args[0] == @name }.map(&:delete)
    end

    def delete_busy_jobs
      workers = Sidekiq::WorkSet.new
      workers.each do |_, _, msg|
        job, repository_name = get_job(msg)
        job.delete if repository_name == @name
      end
    end

    def delete_git_files
      return unless git_repository_path = git_repository_path(@name)

      logger.debug "destroy directory ... #{@name}"
      FileUtils.rm_rf git_repository_path
    end

    private

    def get_job(msg)
      job = Sidekiq::Job.new(msg['payload'])
      repository_name = job.display_args[0]

      [job, repository_name]
    end
  end
end
