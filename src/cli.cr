require "./hpr"

require "option_parser"

module Hpr
  class Cli
    class Error < Exception; end

    enum Action
      Server
      List
      Create
      Update
      Delete
    end

    NEDD_URL_FLAGS = ["-c", "--create"]

    def initialize(args = ARGV)
      @client = Client.new

      @action = Action::Server
      @repo_url = ""
      @repo_name = ""

      @mirror_only = false

      OptionParser.parse(args.dup) do |parser|
        parser.banner = usage

        parser.unknown_args do |unknown_args|
          need_flags = args.select { |v| NEDD_URL_FLAGS.includes?(v) }.size > 0

          if need_flags
            raise Error.new("Missing url argument.") if unknown_args.size.zero?

            @repo_url = unknown_args.first
          end
        end

        parser.separator("\n Actions:\n")
        parser.on("-s", "--server", "Run a web api server (default)") { @action = Action::Server }
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
      end

      run_action
    end

    private def run_action
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
      @client.create_repository(@repo_url, @repo_name, (@mirror_only == true ? "true" : "false"))
    end

    private def update_repository
      @client.update_repository(@repo_name)
    end

    private def delete_repository
      @client.delete_repository(@repo_name)
    end

    private def start_server
      spawn do
        Hpr::API.run
      end

      worker = Faktory::Worker.new
      worker.run
    end

    private def usage
      "Usage: hpr <action> [--name=<name>] <url>"
    end

    private def version
      "hpr v#{Hpr::VERSION} in Crystal v#{Crystal::VERSION}"
    end
  end
end

Hpr::Cli.new
