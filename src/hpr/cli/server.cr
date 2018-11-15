class Hpr::Cli
  class Server < Command
    def run(**args)
      server_port = args[:server_port]

      start_worker
      print_banner
      puts "Using config: #{Hpr.config.config_file}"
      Hpr::API.run(server_port)
    end

    private def print_banner
      puts <<-EOF
  _
 | |__  _ __  _ __
 | '_ \\| '_ \\| '__|
 | | | | |_) | |
 |_| |_| .__/|_|
       |_|
EOF
    end
  end
end
