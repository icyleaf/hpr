# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path(__dir__)

require 'chronic_duration'
require 'active_record'
require 'settingslogic'
require 'fileutils'
require 'sidekiq'
require 'raven'

module Hpr
  class << self
    def init
      init_sentry
      init_sidekiq
      connect_database
    end

    def init_sidekiq
      redis_url = { url: ENV['HPR_REDIS_URL'] || 'redis://localhost:6379/2' }

      Sidekiq.configure_server do |config|
        config.redis = redis_url
      end

      Sidekiq.configure_client do |config|
        config.redis = redis_url
      end

      Sidekiq.default_worker_options = { 'backtrace' => true }

      sidekiq_log_path = create_log_file('sidekiq.log')
      Sidekiq.logger = Logger.new(sidekiq_log_path)
      Sidekiq.logger.level = Logger::DEBUG unless producton?
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
      Raven.configure do |config|
        config.dsn = Hpr::Configuration.sentry.dns
        config.async = lambda { |event| Hpr::SentryWorker.perform_async(event) }
        config.environments = %w[development production]
        config.current_environment = ENV['HPR_ENV'] || 'development'
        config.logger = Logger.new(sentry_log_path)
        config.release = Hpr::VERSION
        config.tags = { running_env: running_env }
        config.tags[:git_commit] = git_rev if git_rev
      end

      Raven.user_context username: hostname
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
      data['basic_auth']['user'] = '*' * 16 unless data['basic_auth']['password'].empty?
      data['basic_auth']['password'] = '*' * 16 unless data['basic_auth']['password'].empty?
      data['gitlab']['private_token'] = '*' * 16
      data
    end
  end
end

require 'hpr/version'
require 'hpr/ext/git_mixin'
require 'hpr/error'
require 'hpr/helper'
require 'hpr/repository'
require 'hpr/client'
require 'hpr/web'
require 'hpr/worker'

# init
Hpr.init
