require "../hpr"
require "option_parser"
require "terminal"

module Hpr
  class Cli
    class Error < Exception; end

    enum Action
      Server
      List
      Search
      Create
      Update
      Delete
      ShowVersion
      ShowHelp
    end

    def initialize(args = ARGV)
      @action = Action::ShowHelp
      @repo_url = ""
      @repo_name = ""
      @create = true
      @clone = true
      @server_port = 8848

      @parser = OptionParser.parse(args) do |op|
        op.banner = usage

        op.separator("\nActions:\n")
        op.on("-s", "--server", "Run a web api server") { @action = Action::Server }
        op.on("-l", "--list", "List mirrored repositories") { @action = Action::List }
        op.on("-S", "--search", "Search mirrored repositories") { @action = Action::Search }
        op.on("-c", "--create", "Create a mirror repository") { @action = Action::Create }
        op.on("-u", "--update", "Updated a mirrored repository") { @action = Action::Update }
        op.on("-d", "--delete", "Delete a mirrored repository") { @action = Action::Delete }
        op.on("-v", "--version", "Show version") { @action = Action::ShowVersion }
        op.on("-h", "--help", "Show this help") { @action = Action::ShowHelp }

        op.separator("\nOption in server action:\n")
        op.on("-P PORT", "--port PORT", "the port of server (by default is 8848)") { |port| @server_port = port.to_i }

        op.separator("\nOption in create action:\n")
        op.on("-U URL", "--url URL", "The url of mirror repository") { |url| @repo_url = url }
        op.on("--no-create", "Do not create project in gitlab") { @create = false }
        op.on("--no-clone", "Do not clone mirror of git repository from url") { @clone = false }

        op.separator("\nGlobal options:\n")
        op.on("-p PATH", "--path PATH", "the path of hpr root directory") { |path| Hpr.config(path) }

        op.separator examples
        op.separator "\n#{version}"

        op.unknown_args do |unknown_args|
          @repo_name = unknown_args.first if unknown_args.size > 0
        end
      end

      @client = Client.new
      run!
    end

    private def run!
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
      when Action::ShowVersion
        puts version
      else Action::ShowHelp
      puts @parser
      end
    end

    private def list_repositories
      repositories = @client.list_repositories.each_with_object([] of Hash(String, String)) do |name, obj|
        obj << Utils.repository_info(name)
      end

      Terminal.message "listing repositories (#{repositories.size}):"
      repositories.each do |repo|
        dump_repository(repo)
      end
    end

    private def search_repositories
      Terminal.message "searching repositories ... #{@repo_name}"
      repositories = @client.search_repositories(@repo_name).each_with_object([] of Hash(String, String)) do |name, obj|
        obj << Utils.repository_info(name)
      end

      Terminal.message "found repositories (#{repositories.size}):"
      repositories.each do |repo|
        dump_repository(repo)
      end
    end

    private def create_repository
      Terminal.user_error! "Missing url argument." if @repo_url.empty?

      @repo_name = Utils.project_name(@repo_url) if @repo_name.empty?
      if Git::Repo.repository_path?(@repo_name)
        Terminal.important "repository exists ... #{@repo_name}"
        repo = Utils.repository_info(@repo_name)
        dump_repository(repo)

        exit
      end

      start_worker
      @client.create_repository(@repo_url, @repo_name, @create, @clone)
      repo = Git::Repo.repository(@repo_name)

      loop do
        sleep 1.seconds
        if !repo.cloning? && (info = Utils.repository_info(@repo_name)) && !info["updated_at"].empty?
          break
        end
      end
      Terminal.success "create repository ... done"
    end

    private def update_repository
      Terminal.user_error! "Missing name argument." if @repo_name.empty?

      start_worker
      @client.update_repository(@repo_name)

      loop do
        sleep 1.seconds
        break unless Utils.repository_updating?(@repo_name)
      end
      Terminal.success "update repository ... done"
    end

    private def delete_repository
      Terminal.user_error! "Missing name argument." if @repo_name.empty?

      start_worker
      @client.delete_repository(@repo_name)
      loop do
        sleep 1.seconds
        break unless Git::Repo.repository_path?(@repo_name)
      end
      Terminal.success "delete repository ... done"
    end

    private def dump_repository(repo)
      puts
      puts "=> Name: #{repo["name"]}"
      puts "   Path: #{Git::Repo.repository_path(repo["name"])}"
      puts "   OriginalUrl: #{repo["url"]}"
      puts "   MirrorUrl: #{repo["mirror_url"]}"
      puts "   Status: #{repo["status"]}"
      puts "   CreatedAt: #{repo["created_at"]}"
      puts "   UpdatedAt: #{repo["updated_at"]}"
      puts "   ScheduledAt: #{repo["scheduled_at"]}"
    end

    private def start_server
      determine_redis!

      start_worker
      print_banner
      puts "Using config: #{Hpr.config.config_file}"
      Hpr::API.run(@server_port)
    end

    private def start_worker
      spawn do
        Hpr::Worker.run
      end

      sleep 100.milliseconds # waiting sidekiq is ready
    end

    private def determine_redis!
      if provider = ENV["REDIS_PROVIDER"]?
        Redis.new(url: ENV[provider])
      end
    rescue e : Exception
      Terminal.error "Can not connect redis server, set both REDIS_PROVIDER and REDIS_URL to environment."
      exit
    end

    private def usage
      "Usage: hpr <action> [--url=<url>] <name>"
    end

    private def version
      "hpr v#{Hpr::VERSION} in Crystal v#{Crystal::VERSION}"
    end

    private def examples
      <<-EOF

Examples:

    o Start a API server:

            $ hpr -s

    o Start a API server with custom port and different config path:

            $ hpr -s --port 3001 --file ~/.config/hpr/hpr.json

    o List all mirrored repositories:

            $ hpr -l

    o Search all repositories include icyleaf keywords:

            $ hpr -S icyleaf

    o Create a new repository:

            $ hpr -c --url https://github.com/icyleaf/hpr.git icyleaf-hpr

    o Clone and push a new repository without create gitlab project:

            $ hpr -c --no-create --url https://github.com/icyleaf/hpr.git icyleaf-hpr

    o Update a repository:

            $ hpr -u icyleaf-hpr

    o Delete a repository:

            $ hpr -d icyleaf-hpr

    More detail to check: https://icyleaf.github.io/hpr/
EOF
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
