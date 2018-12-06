require "sidekiq/cli"
require "sidekiq/sidekiq/api"
require "raven/integrations/sidekiq/exception_handler"

module Hpr
  module Worker
    module Cli
      def run(config)
        server = Sidekiq::Server.new(
          environment: "production",
          logger: file_logger(config.root_path)
        )

        Sidekiq::Client.default_context = Sidekiq::Client::Context.new(
          pool: server.pool,
          logger: server.logger
        )

        server.error_handlers << Raven::Sidekiq::ExceptionHandler.new
        server.logger.info "Sidekiq v#{Sidekiq::VERSION} in Crystal #{Crystal::VERSION}"
        server.logger.info "Starting processing with #{server.concurrency} workers"
        server.start

        channel = Channel(Int32).new

        Signal::INT.trap do
          puts "int"
          server.request_stop
          channel.send 0
        end

        Signal::TERM.trap do
          puts "222"
          server.request_stop
          channel.send 0
        end

        Signal::USR1.trap do
          puts "usr1"
          server.request_stop
          channel.send 0
        end

        channel.receive
        server.logger.info "Done, bye with INT signal"
        exit
      end

      private def file_logger(path : String, file = "logs/sidekiq.log")
        file = File.join path, file
        Dir.mkdir_p File.dirname(file)

        logger = Sidekiq::Logger.build File.open(file, "a")
        logger.level = Logger::DEBUG if Hpr.verbose?
        logger
      end
    end

    module Base
      macro included
        include Sidekiq::Worker
        include Git::Helper
      end

      {% for ivar in %w(info debug error warn fatal) %}
        def {{ ivar.id }}(*msg)
          logger.{{ ivar.id }}("[#{self.class.name}] #{msg.join(" ")}")
        end
      {% end %}

      private def set_schedule_time(name, repository_path, schedule_time)
        return if has_scheduled? name
        debug "scheduling next update at #{schedule_time} ... #{name}"
        UpdateRepositoryWorker.async.perform_at schedule_time, name, repository_path, schedule_time
      end

      private def has_scheduled?(name)
        scheduled = Sidekiq::ScheduledSet.new
        rs = scheduled.select { |s| s.args[0].to_s == name }
        rs.empty? ? nil : rs.first
      end
    end

    extend Cli
  end
end

require "./workers/*"
