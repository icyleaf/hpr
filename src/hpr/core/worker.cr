require "sidekiq/cli"
require "sidekiq/sidekiq/api"
require "raven/integrations/sidekiq/exception_handler"

module Hpr
  module Worker
    module Cli
      def run(config)
        server = Sidekiq::Server.new(
          environment: "production",
          queues: ["hpr"],
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

        channel = Channel(String).new

        Signal::INT.trap do
          server.request_stop
          channel.send "INT"
        end

        Signal::TERM.trap do
          server.request_stop
          channel.send "Quiet (TERM)"
        end

        Signal::USR1.trap do
          server.request_stop
          channel.send "Stop (USR1)"
        end

        sigal = channel.receive
        server.logger.info "Done, bye with #{sigal} signal"
        exit
      end

      private def file_logger(path : String, file = "logs/sidekiq.log")
        file = File.join path, file
        Dir.mkdir_p File.dirname(file)

        logger = Sidekiq::Logger.build File.open(file, "a"), "Asia/Shanghai"
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
        return if (jobs = has_scheduled?(name)) && jobs.size > 1 # May be the current worker is still in schedule list.

        debug "scheduling next update at #{schedule_time} ... #{name}"
        UpdateRepositoryWorker.async.perform_at schedule_time, name, repository_path, schedule_time
      end

      private def has_scheduled?(name)
        scheduled = Sidekiq::ScheduledSet.new
        rs = scheduled.select { |s| s.args[0].to_s == name }
        return rs unless rs.empty?
      end
    end

    extend Cli
  end
end

require "./workers/*"
