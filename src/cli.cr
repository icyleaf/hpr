require "./hpr"

require "option_parser"

module Hpr
  class Cli
    class Error < Exception; end

    enum Action
      None
      Server
      List
      Search
      Create
      Update
      Delete
    end

    def initialize(args = ARGV)
      @client = Client.new

      @action = Action::None
      @repo_url = ""
      @repo_name = ""
      @mirror_only = false
      @server_port = 8848

      parser = OptionParser.parse(args) do |parser|
        parser.banner = usage

        parser.separator("\nActions:\n")
        parser.on("-s", "--server", "Run a web api server") { @action = Action::Server }
        parser.on("-l", "--list", "List mirrored repositories") { @action = Action::List }
        parser.on("-S", "--search", "Search mirrored repositories") { @action = Action::Search }
        parser.on("-c", "--create", "Create a mirror repository") { @action = Action::Create }
        parser.on("-u", "--update", "Updated a mirrored repository") { @action = Action::Update }
        parser.on("-d", "--delete", "Delete a mirrored repository") { @action = Action::Delete }

        parser.separator("\nOption in server action:\n")
        parser.on("-P PORT", "--port PORT", "the port of server (by default is 8848)") { |port| @server_port = port.to_i }

        parser.separator("\nOption in create action:\n")
        parser.on("-U URL", "--url URL", "The url of mirror repository") { |url| @repo_url = url }
        parser.on("-M", "--mirror-only", "Only mirror the repository without clone in create action") { @mirror_only = true }

        parser.separator("\nGlobal options:\n")
        parser.on("-v", "--version", "Show version") { puts version }
        parser.on("-h", "--help", "Show this help") { puts parser }

        parser.separator <<-EXAMPLES
\nExamples:

       o Start a API server:

               $ hpr -s

       o List all mirrored repositories:

               $ hpr -l

       o Start a API server with custom port:

               $ hpr -s --port 3001

       o Search all repositories include icyleaf keywords:

               $ hpr -S icyleaf

       o Create a new repository:

               $ hpr -c --url https://github.com/icyleaf/hpr.git icyleaf-hpr

       o Clone and push a new repository without create gitlab project:

               $ hpr -c --mirror-only --url https://github.com/icyleaf/hpr.git icyleaf-hpr

       o Update a repository:

               $ hpr -u icyleaf-hpr

       o Delete a repository:

               $ hpr -d icyleaf-hpr

       More detail to check: https://icyleaf.github.io/hpr/
EXAMPLES

        parser.separator("\n#{version}")

        parser.unknown_args do |unknown_args|
          @repo_name = unknown_args.first if unknown_args.size > 0
        end
      end

      if @action != Action::None
        run
      end
    end

    private def run
      case @action
      when Action::Server
        start_server
      when Action::List
        list_repositories
      when Action::Search
        search_repositories
      when Action::Create
        create_repository
      when Action::Update
        update_repository
      when Action::Delete
        delete_repository
      end
    end

    private def list_repositories
      repositories = @client.list_repositories.each_with_object([] of Hash(String, String)) do |name, obj|
        obj << Utils.repository_info(name)
      end

      Hpr.logger.info "listing repositories (#{repositories.size}):"
      repositories.each do |repo|
        dump_repository(repo)
      end
    end

    private def search_repositories
      Hpr.logger.info "searching repositories ... #{@repo_name}"
      repositories = @client.search_repositories(@repo_name).each_with_object([] of Hash(String, String)) do |name, obj|
        obj << Utils.repository_info(name)
      end

      Hpr.logger.info "found repositories (#{repositories.size}):"
      repositories.each do |repo|
        dump_repository(repo)
      end
    end

    private def create_repository
      Utils.user_error! "Missing url argument." if @repo_url.empty?

      @repo_name = Utils.project_name(@repo_url) if @repo_name.empty?
      if Utils.repository_path?(@repo_name)
        Hpr.logger.info "repository exists ... #{@repo_name}"
        repo = Utils.repository_info(@repo_name)
        dump_repository(repo)

        exit
      end

      start_worker
      sleep 100.milliseconds # waiting sidekiq is ready

      @client.create_repository(@repo_url, @repo_name, @mirror_only)
      loop do
        sleep 1.seconds
        if !Utils.repository_cloning?(@repo_name) &&
           (info = Utils.repository_info(@repo_name)) &&
           !info["updated_at"].empty?
          break
        end
      end
      Hpr.logger.info "create repository ... done"
    end

    private def update_repository
      Utils.user_error! "Missing name argument." if @repo_name.empty?

      start_worker
      sleep 1.seconds # waiting sidekiq is ready
      @client.update_repository(@repo_name)

      loop do
        sleep 1.seconds
        break unless Utils.repository_updating?(@repo_name)
      end
      Hpr.logger.info "update repository ... done"
    end

    private def delete_repository
      Utils.user_error! "Missing name argument." if @repo_name.empty?

      start_worker
      sleep 1.seconds # waiting sidekiq is ready

      @client.delete_repository(@repo_name)
      loop do
        sleep 1.seconds
        break unless Utils.repository_path?(@repo_name)
      end
      Hpr.logger.info "delete repository ... done"
    end

    private def dump_repository(repo)
      puts
      puts "=> Name: #{repo["name"]}"
      puts "   Path: #{Utils.repository_path(repo["name"])}"
      puts "   OriginalUrl: #{repo["url"]}"
      puts "   MirrorUrl: #{repo["mirror_url"]}"
      puts "   Status: #{repo["status"]}"
      puts "   CreatedAt: #{repo["created_at"]}"
      puts "   UpdatedAt: #{repo["updated_at"]}"
      puts "   ScheduledAt: #{repo["scheduled_at"]}"
    end

    private def start_server
      print_banner
      start_worker

      Hpr::API.run(@server_port)
    end

    private def start_worker
      spawn do
        Hpr::Worker.run
      end
    end

    private def usage
      "Usage: hpr <action> [--url=<url>] <name>"
    end

    private def version
      "hpr v#{Hpr::VERSION} in Crystal v#{Crystal::VERSION}"
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

Hpr::Cli.new
