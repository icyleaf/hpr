require "../hpr"
require "option_parser"
require "terminal"

module Hpr
  class Cli
    include Git::Helper

    class Error < Exception; end

    abstract class Command
      include Git::Helper

      @client : Hpr::Client?

      def self.run(**args)
        new.run(**args)
      end

      abstract def run(**args)

      protected def client
        @client ||= Client.new
        @client.not_nil!
      end

      protected def dump_repository(repo)
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

      protected def wait_updating(name, progress = false)
        loop do
          print "." if progress
          sleep 1.seconds
          unless repository_updating?(name)
            puts if progress
            break
          end
        end
      end

      protected def start_worker
        spawn do
          Hpr::Worker.run
        end

        sleep 100.milliseconds # waiting sidekiq is ready
      end

      protected def determine_redis!
        if provider = ENV["REDIS_PROVIDER"]?
          Redis.new(url: ENV[provider])
        end
      rescue e : Exception
        Terminal.error "Can not connect redis server, set both REDIS_PROVIDER and REDIS_URL to environment."
        exit
      end
    end

    enum Action
      Server
      List
      Search
      Create
      Update
      Delete
      Migration
      ShowVersion
      ShowHelp
    end

    def initialize(args = ARGV)
      @action = Action::ShowHelp

      # server opts
      @server_port = 8848

      # create/update/delete/search opts
      @repo_name = ""

      # create/update/delete opts
      @progress = false

      # create opts
      @repo_url = ""
      @create = true
      @clone = true

      # migration
      @source = "gitlab-mirrors"
      @preview_mode = false

      @parser = OptionParser.parse(args) do |op|
        op.banner = usage
        op.separator help

        op.separator("\nOption in server command:\n")
        op.on("-P PORT", "--port PORT", "the port of server (by default is #{@server_port})") { |port| @server_port = port.to_i }

        op.separator("\nOption in create command:\n")
        op.on("-U URL", "--url URL", "The url of mirror repository") { |url| @repo_url = url }
        op.on("--no-create", "Do not create project in gitlab") { @create = false }
        op.on("--no-clone", "Do not clone mirror of git repository from url") { @clone = false }

        op.separator("\nOption in create/update/delete command:\n")
        op.on("--progress", "show progress") { @progress = true }

        op.separator("\nOption in migration command:\n")
        op.on("-s SOURCE", "--source SOURCE", "The source of migration came from (avaiable gitlab-mirrors only)") { |source| @source = source }
        op.on("--preview", "list repositories to see the actions") { @preview_mode = true }

        op.separator("\nGlobal options:\n")
        op.on("-p PATH", "--path PATH", "the path of hpr root directory") { |path| Hpr.config(path) }
        op.on("--no-color", "disable colorize output") { Terminal.disable_color }

        op.separator examples
        op.separator "\n#{version}"

        op.unknown_args do |unknown_args|
          unless unknown_args.empty?
            @action = case unknown_args.first.downcase
                      when "server"
                        Action::Server
                      when "list"
                        Action::List
                      when "create"
                        Action::Create
                      when "update"
                        Action::Update
                      when "delete"
                        Action::Delete
                      when "migration"
                        Action::Migration
                      when "version"
                        Action::ShowVersion
                      else
                        Action::ShowHelp
                      end

            if [Action::Update, Action::Delete, Action::Search, Action::Migration].includes?(@action)
              if unknown_args.size != 2
                message = if @action == Action::Migration
                            "Missing the path of source, run `hpr migration [--source <name>] [source-path]"
                          else
                            "Missing the name of repository, run `hpr #{@action.to_s.downcase} [name]`"
                          end
                Terminal.error message
                exit
              end

              @repo_name = unknown_args[1]
            end
          end
        end
      end

      @client = Client.new
      run
    end

    private def run
      case @action
      when Action::Server
        Server.run(server_port: @server_port)
      when Action::Create
        Create.run(url: @repo_url, name: @repo_name, create: @create, clone: @clone, progress: @progress)
      when Action::Update
        Update.run(name: @repo_name, progress: @progress)
      when Action::Delete
        Delete.run(name: @repo_name, progress: @progress)
      when Action::List
        List.run
      when Action::Search
        Search.run(name: @repo_name)
      when Action::Migration
        Migration.run(source: @source, source_path: @repo_name, preview_mode: @preview_mode)
      when Action::ShowVersion
        puts version
      else Action::ShowHelp
      puts @parser
      end
    end

    private def usage
      <<-EOF
hpr is the main command, used to manage git repositories.

Usage:
    hpr [command]
EOF
    end

    private def help
      <<-EOF

Available Commands:
    server    Run a web api server
    list      List mirrored repositories
    search    Search mirrored repositories
    create    Create a mirror repository
    update    Updated a mirrored repository
    delete    Delete a mirrored repository
    version   Show version
    help      Show this help
EOF
    end

    private def examples
      <<-EOF

Examples:
    o Start a API server:
      $ hpr server

    o Start a API server with custom port and different hpr path:
      $ hpr server --port 3001 --path ~/path/to/hpr

    o List all mirrored repositories:
      $ hpr list

    o Search all repositories include halite keywords:
      $ hpr search halite

    o Create a new repository:
      $ hpr create --url https://github.com/icyleaf/hpr.git icyleaf-hpr

    o Clone and push a new repository without create gitlab project:
      $ hpr create --no-create --url https://github.com/icyleaf/hpr.git icyleaf-hpr

    o Update a repository:
      $ hpr update icyleaf-hpr

    o Delete a repository:
      $ hpr delete icyleaf-hpr

    More detail to check: https://icyleaf.github.io/hpr/
EOF
    end

    private def version
      "hpr v#{Hpr::VERSION} in Crystal v#{Crystal::VERSION}"
    end
  end
end

require "./cli/*"
