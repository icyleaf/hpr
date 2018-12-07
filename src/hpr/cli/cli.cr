require "option_parser"
require "terminal"
require "redis"
require "../core/core"
require "../core/config"
require "../core/client"

module Hpr
  class Cli
    class Error < Exception; end

    enum Action
      Check
      Server
      List
      Search
      Create
      Update
      Delete
      Upgrade
      Migration
      ShowVersion
      ShowHelp
    end

    def initialize
      @action = Action::ShowHelp
      @config_path = "config"

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

      @parser = OptionParser.parse! do |op|
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
        op.on("-p PATH", "--path PATH", "the path of hpr root directory") { |path| @config_path = File.join(path, "config") }
        op.on("--verbose", "Show debug information") { ENV["HPR_VERBOSE"] = "true" }
        op.on("--no-color", "disable colorize output") { Terminal.disable_color }

        op.separator examples

        op.unknown_args do |unknown_args|
          unless unknown_args.empty?
            @action = case unknown_args.first.downcase
                      when "check"
                        Action::Check
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
                      when "search"
                        Action::Search
                      when "migration"
                        Action::Migration
                      when "upgrade"
                        Action::Upgrade
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

      run!
    end

    private def run!
      case @action
      when Action::Check
        Check.run!(path: @config_path)
      when Action::Server
        Server.run!(path: @config_path, server_port: @server_port)
      when Action::Create
        Create.run!(path: @config_path, url: @repo_url, name: @repo_name, create: @create, clone: @clone, progress: @progress)
      when Action::Update
        Update.run!(path: @config_path, name: @repo_name, progress: @progress)
      when Action::Delete
        Delete.run!(path: @config_path, name: @repo_name, progress: @progress)
      when Action::List
        List.run!(path: @config_path)
      when Action::Search
        Search.run!(path: @config_path, name: @repo_name)
      when Action::Migration
        Migration.run!(path: @config_path, source: @source, source_path: @repo_name, preview_mode: @preview_mode)
      when Action::Upgrade
        Upgrade.run!(path: @config_path)
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
    server      Run a web api server
    list        List mirrored repositories
    search      Search mirrored repositories
    create      Create a mirror repository
    update      Updated a mirrored repository
    delete      Delete a mirrored repository
    check       Contains some verification checks
    migration   Migration tools
    version     Show version
    help        Show this help
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

    o Search all repositories include icyleaf keywords:
      $ hpr search icyleaf

    o Create a new repository:
      $ hpr create --url https://github.com/icyleaf/hpr.git icyleaf-hpr

    o Clone and push a new repository without create gitlab project:
      $ hpr create --no-create --url https://github.com/icyleaf/hpr.git icyleaf-hpr

    o Update a repository:
      $ hpr update icyleaf-hpr

    o Delete a repository:
      $ hpr delete icyleaf-hpr

    o Migrate from gitlab-mirrors with gitmirrors group name:
      $ hpr migration --source gitlab-mirrors /home/gitmirror/repositories/gitmirrors/

More detail to check: https://icyleaf.github.io/hpr/
EOF
    end

    private def version
      "hpr v#{Hpr::VERSION} in Crystal v#{Crystal::VERSION}"
    end

    abstract class Command
      def self.run!(**args)
        path = args[:path]
        new(path).run!(**args)
      end

      @client : Hpr::Client?
      @config : Hpr::Config

      def initialize(@path : String)
        determine!
        @config = Hpr::Config.load(@path)

        Hpr.init(@config)

        Raven.breadcrumbs.record do |crumb|
          crumb.category = "cli"
          crumb.timestamp = Time.now
          crumb.message = "Perpare to run #{self.class} command"
        end
      end

      abstract def run(**args)

      def run!(**args)
        run(**args)
      rescue ex : Exception
        Hpr.capture_exception(ex, "cli", print_output_error: true)
      end

      protected def client
        @client ||= Hpr::Client.new(@config)
        @client.not_nil!
      end

      protected def dump_repository(model, path)
        puts
        puts "=> Name: #{model.name}"
        puts "   Path: #{path}"
        puts "   OriginalUrl: #{model.url}"
        puts "   MirrorUrl: #{model.mirror_url}"
        puts "   Status: #{model.status}"
        puts "   CreatedAt: #{model.created_at}"
        puts "   UpdatedAt: #{model.updated_at}"
        puts "   ScheduledAt: #{model.scheduled_at}"
      end

      protected def wait_updating(name, progress = false)
        loop do
          print "." if progress
          sleep 1.seconds
          unless client.repository_updating?(name)
            puts if progress
            break
          end
        end
      end

      protected def start_worker
        spawn do
          Hpr::Worker.run(@config)
        end

        sleep 100.milliseconds # waiting sidekiq is ready
      end

      protected def determine!
        determine_config!
        determine_redis!
      end

      protected def determine_config!
        unless has_config?
          Terminal.error "Can not location hpr.json in #{@path}"
          exit
        end
      end

      protected def has_config?
        path = File.expand_path(@path)
        config_file = File.join(path, "hpr.json")
        File.file?(config_file)
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
  end
end

require "./commands/*"
