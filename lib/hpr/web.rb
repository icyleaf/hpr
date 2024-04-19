# frozen_string_literal: true

require 'sinatra'
require 'sinatra/json'
require 'sinatra/required_params'
require 'sinatra/streaming'
require 'sidekiq/api'

module Hpr
  # Web API Application
  class Web < Sinatra::Base
    helpers Sinatra::RequiredParams
    helpers Sinatra::Streaming

    configure do
      use Rack::CommonLogger, Logger.new($stdout)
      use Sentry::Rack::CaptureExceptions

      if Configuration.basic_auth?
        use Rack::Auth::Basic, 'HPR Auth' do |username, password|
          username == Configuration.basic_auth.user.to_s &&
            password == Configuration.basic_auth.password.to_s
        end
      end

      set :show_exceptions, :after_handler
    end

    get '/' do
      json message: 'Welcome to hpr api layer'
    end

    get '/info' do
      json hpr: { version: Hpr::VERSION }, jobs: jobs
    end

    get '/info/scheduled' do
      json scheduled_jobs
    end

    get '/info/busy' do
      json busy_jobs
    end

    get '/info/retry_failtures' do
      json retry_failures_jobs
    end

    unless Hpr::Configuration.api.disable_config
      get '/config' do
        json Hpr::Configuration.to_safe_h
      end
    end

    get '/repositories' do
      total = client.total_repositories
      page = params.fetch('page', '1').to_i
      per_page = params.fetch('per_page', '50').to_i

      json total: total, entry: client.list_repositories(page, per_page)
    end

    get '/repositories/search' do
      required_params :q
      repositories = client.search_repositories(params['q'])

      json entry: repositories
    end

    get '/repositories/:name' do
      name = params['name']
      repository = repository_or_404(name)
      json repository
    end

    get '/repositories/:name/status' do
      name = params['name']
      repository = repository_or_404(name)

      job = (jobs = busy_jobs(name)) && jobs.size == 1 ? jobs.first : nil
      stream do |out|
        loop do
          body = { status: repository.status }
          if job
            body[:started_at] = job[:started_at]
            body[:job] = job[:job]
          end

          out.puts JSON.dump(body)
          out.flush

          break if repository.status == 'idle'

          sleep 1
        end
      end
    end

    post '/repositories' do
      required_params :url

      url = params['url']
      name = params['name']
      create = params['create'] || 'true'
      clone = params['clone'] || 'true'

      job_id = client.create_repository(
        url, name,
        create == 'true',
        clone == 'true'
      )

      status 201
      json job_id: job_id
    end

    put '/repositories/:name' do
      name = params['name']
      job_id = client.update_repository(name)

      json job_id: job_id
    end

    delete '/repositories/:name' do
      job_id = client.destory_repository(params['name'])

      json job_id: job_id
    end

    error do
      json message: 'Sorry there was a nasty error - ' + env['sinatra.error'].message
    end

    error 400 do
      json message: '缺少必要的参数，请仔细检查后重试。'
    end

    error Hpr::NotFoundError do
      status 404
      json message: env['sinatra.error'].message
    end

    error Hpr::MissingSSHKeyError, Hpr::NotRoleError do
      status 403
      json message: env['sinatra.error'].message
    end

    error 500 do
      json message: env['sinatra.error'].message
    end

    helpers do
      def repository_or_404(name)
        repository = client.repository(name)
        halt 404, json(message: "Not found repository #{name}") unless repository

        repository
      end
    end

    private

    def client
      @client ||= Hpr::Client.new
    end

    def jobs
      sidekiq_stats = Sidekiq::Stats.new
      {
        processed: sidekiq_stats.processed,
        failed: sidekiq_stats.failed,
        retry_failures: Sidekiq::Failures.count,
        busy: sidekiq_stats.workers_size,
        processes: sidekiq_stats.processes_size,
        enqueued: sidekiq_stats.enqueued,
        scheduled: sidekiq_stats.scheduled_size,
        retries: sidekiq_stats.retry_size,
        dead: sidekiq_stats.dead_size,
        default_latency: sidekiq_stats.default_queue_latency,
      }
    end

    def busy_jobs(name = nil)
      workers = Sidekiq::WorkSet.new
      entry = []
      workers.each do |process, thread, msg|
        job = Sidekiq::JobRecord.new(msg['payload'])
        worker_type = job.display_class[5..].downcase
        repository = job.display_args[0]

        stats = {
          jid: job.jid,
          worker: worker_type,
          repository: repository,
          process: process,
          thread: thread,
          started_at: Time.at(msg['run_at'])
        }

        return [stats] if name && repository == name

        entry << stats
      end

      entry
    end

    def scheduled_jobs
      scheduled_set = Sidekiq::ScheduledSet.new
      scheduled_set.each_with_object([]) do |retri, obj|
        obj << {
          name: retri.item['args'].first,
          scheduled_at: retri.at
        }
      end
    end

    def retry_failures_jobs
      failure_set = Sidekiq::Failures::FailureSet.new
      failure_set.each_with_object([]) do |set, obj|
        data = set.item
        obj << {
          name: data['args'].first,
          worker: data['class'][5..].downcase,
          error_class: data['error_class'],
          error_message: data['error_message'],
          failed_at: data['failed_at'],
          aaa: set
        }
      end
    end
  end
end
