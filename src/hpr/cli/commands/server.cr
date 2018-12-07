require "../../web/server"

class Hpr::Cli
  class Server < Command
    def run(**args)
      server_port = args[:server_port]

      start_worker
      print_banner
      puts "Verbose mode" if Hpr.verbose?
      Hpr::Server.run(@config, server_port)
    end

    private def print_banner
      puts <<-EOF
  _
 | |__  _ __  _ __
 | '_ \\| '_ \\| '__|
 | | | | |_) | |
 |_| |_| .__/|_|
       |_|         v#{Hpr::VERSION}
EOF
    end
  end
end
