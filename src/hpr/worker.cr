require "sidekiq/cli"

module Hpr
  module Worker
    module Base
      macro included
        include Sidekiq::Worker
      end

      {% for ivar in %w(info debug error warn fatal) %}
        def {{ ivar.id }}(*msg)
          logger.{{ ivar.id }}("[#{self.class.name}] #{msg.join(" ")}")
        end
      {% end %}

      private def update_schedule(name)
        return if has_scheduled?(name)

        schedule_in = Hpr.config.schedule_in
        info "setting schedule worker at #{schedule_in.from_now}"
        UpdateRepositoryWorker.async.perform_in(schedule_in, name)

        repo = Git::Repo.repository(name)
        repo.set_config("hpr.scheduled", schedule_in.from_now.to_s("%F %T %z"))
      end

      private def has_scheduled?(name)
        scheduled = Sidekiq::ScheduledSet.new
        !scheduled.select {|s| s.args[0].to_s == name}.size.zero?
      end
    end

    module Cli
      def run
        server = Sidekiq::Server.new(
          environment: "production",
          logger: file_logger
        )

        Sidekiq::Client.default_context = Sidekiq::Client::Context.new(
          pool: server.pool,
          logger: server.logger
        )

        server.logger.info "Sidekiq v#{Sidekiq::VERSION} in Crystal #{Crystal::VERSION}"
        server.logger.info "Starting processing with #{server.concurrency} workers"
        server.start

        channel = Channel(Int32).new

        Signal::INT.trap do
          server.request_stop
          channel.send 0
        end

        Signal::TERM.trap do
          server.request_stop
          channel.send 0
        end

        Signal::USR1.trap do
          server.request_stop
          channel.send 0
        end

        channel.receive
        server.logger.info "Done, bye with INT signal"
        exit
      end

      private def file_logger(file = "logs/sidekiq.log")
        FileUtils.mkdir_p(File.dirname(file))
        io = File.open(file, "a")

        Sidekiq::Logger.build(io)
      end
    end

    extend Cli
  end
end

require "./workers/*"
