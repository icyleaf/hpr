require "file_utils"
require "gitlab"

module Hpr
  class Client
    property gitlab : Gitlab::Client
    property config : Config

    @user : JSON::Any
    @group : JSON::Any

    def initialize(config_file = "config/hpr.json")
      @config = Config.load config_file
      @gitlab = Gitlab.client(@config.gitlab.endpoint, @config.gitlab.private_token)
      @user = current_user
      @group = current_group

      determine_repository_path!
      determine_gitlab_configure!
    end

    def list_repositories
      Dir.glob(File.join(@config.repository_path, "*")).each_with_object([] of String) do |file, obj|
        next unless File.directory?(file)

        project_name = file.split("/").last
        obj << project_name
      end
    end

    def create_repository(url : String, name : String? = nil)
      repo = Repository.new url
      repo.name = name if name

      raise RepositoryExistsError.new "Exists Repository: #{repo.name}" if reopsitory_exists?(repo.name)

      loop do
        begin
          @gitlab.create_project @user["id"].as_i, repo.name, {"namespace_id" => @group["id"].to_s}
          break
        rescue e : Gitlab::Error::BadRequest
          if (message = e.message) && message.includes?("still being deleted")
            sleep 1
          end
        end
      end

      CloneRepositoryJob.perform_async repo.url, repo.name, @config
    end

    def update_repository(name : String)
      raise NotFoundRepositoryError.new "Not found repository: #{name}" unless reopsitory_exists?(repo.name)

      UpdateRepositoryJob.perform_aync name, @config
    end

    def delete_repository(name : String)
      projects = @gitlab.group_projects @group["id"].as_i, {"search" => name}
      unless projects.as_a.empty?
        project = projects[0]

        r = @gitlab.delete_project project["id"].as_i
      end

      DeleteRepositoryJob.perform_async name, @config
    end

    def delete_repository(all = true)
      list_repositories.each do |name|
        delete_repository name
      end
    end

    def reopsitory_exists?(name)
      Dir.exists?(File.join(@config.repository_path, name))
    end

    def determine_gitlab_configure!
      raise NotRoleError.new "Please enable create group role" unless @user["can_create_group"].as_bool
      raise NotRoleError.new "Please enable create project role" unless @user["can_create_project"].as_bool

      ssh_keys = @gitlab.ssh_keys
      raise MissingSSHKeyError.new "Please add ssh key for '#{@user["name"]}' user." if ssh_keys.as_a.empty?
    end

    private def determine_repository_path!
      path = @config.repository_path
      unless Dir.exists?(path)
        FileUtils.mkdir_p path
      end
    end

    private def current_user
      @gitlab.user
    end

    private def current_group
      @gitlab.group @config.gitlab.group_name
    rescue Gitlab::Error::NotFound
      @gitlab.create_group @config.gitlab.group_name, @config.gitlab.group_name
    end
  end
end
