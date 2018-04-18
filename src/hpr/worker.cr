require "sidekiq/cli"

module Hpr
  module Worker
    extend self

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
end

require "./workers/*"
