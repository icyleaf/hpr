require "./hpr"

require "option_parser"

module Hpr
  class Cli
    class Error < Exception; end

    enum Action
      None
      Server
      List
      Create
      Update
      Delete
    end

    NEDD_URL_FLAGS = ["-c", "--create"]

    def initialize(args = ARGV)
      @client = Client.new

      @action = Action::None
      @repo_url = ""
      @repo_name = ""
      @mirror_only = false

      need_flags = args.select { |v| NEDD_URL_FLAGS.includes?(v) }.size > 0

      parser = OptionParser.parse(args) do |parser|
        parser.banner = usage

        parser.separator("\nActions:\n")
        parser.on("-s", "--server", "Run a web api server (port 8848)") { @action = Action::Server }
        parser.on("-l", "--list", "List mirrored repositories") { @action = Action::List }
        parser.on("-c", "--create", "Create a mirror repository") { @action = Action::Create }
        parser.on("-u", "--update", "Updated a mirrored repository") { @action = Action::Update }
        parser.on("-d", "--delete", "Delete a mirrored repository") { @action = Action::Delete }

        parser.separator("\nOption in create action:\n")
        parser.on("--mirror-only", "Only mirror the repository without clone in create action") { @mirror_only = true }

        parser.separator("\nOption in create/update/delete action:\n")
        parser.on("--name NAME", "The name of mirror repository") { |n| @repo_name = n }

        parser.separator("\nGlobal options:\n")
        parser.on("-v", "--version", "Show version") { puts version }
        parser.on("-h", "--help", "Show this help") { puts parser }

        parser.separator("\n#{version}")

        parser.unknown_args do |unknown_args|
          if need_flags
            raise Error.new("Missing url argument.") if unknown_args.size.zero?

            @repo_url = unknown_args.first
          end
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
        obj << Utils.repository_info(name) if Utils.repository_path?(name)
      end

      puts "Here are #{repositories.size} mirrored repositories:\n"
      @client.list_repositories.each do |repository|
        puts "* #{repository}"
      end
    end

    private def create_repository
      start_worker
      sleep 100.milliseconds # waiting sidekiq is ready

      @repo_name = Utils.project_name(@repo_url) if @repo_name.empty?
      if Utils.repository_path?(@repo_name)
        project_path = Utils.repository_path(@repo_name)
        project_info = Utils.repository_info(@repo_name)

        puts "repository was exists ... #{@repo_name}"
        puts "* path: #{project_path}"
        puts "* original url: #{project_info["url"]}"
        puts "* mirror url: #{project_info["mirror_url"]}"
        puts "* status: #{project_info["status"]}"
        puts "* created at: #{project_info["created_at"]}"
        puts "* updated at: #{project_info["updated_at"]}"
        puts "* scheduled at: #{project_info["scheduled_at"]}"

        exit
      end

      @client.create_repository(@repo_url, @repo_name, @mirror_only)
      print "* repository is creating "
      loop do
        sleep 1.seconds
        print "."

        if !Utils.repository_cloning?(@repo_name) &&
           (info = Utils.repository_info(@repo_name)) &&
           !info["updated_at"].empty?
          break
        end
      end
      puts " [done]"
    end

    private def update_repository
      start_worker
      sleep 1.seconds # waiting sidekiq is ready
      @client.update_repository(@repo_name)

      print "* repository is updating "
      loop do
        sleep 1.seconds
        print "."

        break unless Utils.repository_updating?(@repo_name)
      end
      puts " [done]"
    end

    private def delete_repository
      start_worker
      sleep 1.seconds # waiting sidekiq is ready

      print "* repository is deleting "
      @client.delete_repository(@repo_name)
      loop do
        sleep 1.seconds
        print "."

        break unless Utils.repository_path?(@repo_name)
      end
      puts " [done]"
    end

    private def start_server
      print_banner
      start_worker

      Hpr::API.run
    end

    private def start_worker
      spawn do
        Hpr::Worker.run
      end
    end

    private def usage
      "Usage: hpr <action> [--name=<name>] [<url>]"
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
