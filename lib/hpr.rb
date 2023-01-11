# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path(__dir__)

require 'chronic_duration'
require 'active_record'
require 'settingslogic'
require 'sentry-ruby'
require 'fileutils'
require 'sidekiq'
require 'sidekiq/failures'

module Hpr
  class << self
    def init
      init_sentry
      init_sidekiq
      # configure_git_config
      connect_database
    end

    def init_sidekiq
      redis_url = { url: ENV['HPR_REDIS_URL'] || 'redis://localhost:6379/2' }

      Sidekiq.default_job_options = { 'backtrace' => true }
      Sidekiq.configure_server do |config|
        config.redis = redis_url
        config.logger = Sidekiq::Logger.new(STDOUT)
        config.logger.level = Logger::DEBUG unless producton?
      end

      Sidekiq.configure_client do |config|
        config.redis = redis_url
      end
    end

    def connect_database
      ActiveRecord::Base.establish_connection(
        adapter: 'sqlite3',
        database: Hpr.db_file
      )
    end

    def init_sentry
      return unless Hpr::Configuration.sentry_enable?

      sentry_log_path = create_log_file('sentry.log')
      Sentry.init do |config|
        config.dsn = Hpr::Configuration.sentry.dns
        config.breadcrumbs_logger = %i[sentry_logger http_logger]
        config.capture_exception_frame_locals = true
        config.send_default_pii = true
        config.release = release_info
        config.enabled_environments = %w[development production]
        config.environment = ENV['HPR_ENV'] || 'development'
        config.background_worker_threads = 5
        config.debug = true  unless producton?
        config.logger = Sentry::Logger.new(sentry_log_path)

        config.excluded_exceptions += [
          'Hpr::RepositoryExistsError',
          'Interrupt',
          'SystemExit',
        ]
      end

      Sentry.set_user(username: hostname)
    end

    def configure_git_config
      # Git 2.10+ required, not big issue.
      ::Git.global_config('core.sshCommand', 'ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no')
    end

    def release_info
      [
        Hpr::VERSION,
        running_env,
        git_rev
      ].compact.join('-')
    end

    def running_env
      ENV.fetch('HPR_RUNNING', 'script')
    end

    def hostname
      @hostname ||= `hostname`.strip
    end

    def git_rev
      @git_rev ||= `git rev-parse HEAD`.strip if File.directory?(File.join(root, '.git'))
    end

    def producton?
      env == 'production'
    end

    def env
      ENV['HPR_ENV']
    end

    def root
      File.expand_path('..', __dir__)
    end

    def db_file
      File.join(root, 'repositories', 'hpr.sqlite')
    end

    private

    def create_log_file(filename)
      path = File.join(Hpr.root, 'logs')
      FileUtils.mkdir_p(path) unless Dir.exist?(path)

      File.join(path, filename)
    end
  end

  class Configuration < Settingslogic
    source "#{Hpr.root}/config/hpr.yml" if File.file?("#{Hpr.root}/config/hpr.yml")

    self['repository_path'] = File.join(Hpr.root, 'repositories', gitlab.group_name)

    def self.schedule_in_seconds
      case schedule_in
      when String
        ChronicDuration.parse schedule_in.sub('.', ' ')
      else
        schedule_in.to_i
      end
    end

    def self.basic_auth?
      basic_auth.enable
    end

    def self.sentry_enable?
      sentry.report
    end

    def to_safe_h
      data = to_h.dup
      data['gitlab']['endpoint'] =
      data['basic_auth']['user'] = '*' * 16 unless data['basic_auth']['password'].to_s.empty?
      data['basic_auth']['password'] = '*' * 16 unless data['basic_auth']['password'].to_s.empty?
      data['gitlab']['private_token'] = '*' * 16
      data
    end
  end
end

require 'hpr/ext/git_mixin'
require 'hpr/repository'
require 'hpr/version'
require 'hpr/helper'
require 'hpr/client'
require 'hpr/worker'
require 'hpr/error'
require 'hpr/web'

# init
Hpr.init
