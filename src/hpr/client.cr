require "file_utils"
require "json"

module Hpr
  class Client
    @user : JSON::Any
    @group : JSON::Any
    @namespace : JSON::Any

    def initialize
      @user = current_user
      @group = current_group
      @namespace = group_namespace

      determine_git!
      determine_repository_path!
      determine_gitlab_configure!
    end

    def list_repositories
      Dir.glob(File.join(Hpr.config.repository_path, "*")).each_with_object([] of String) do |file, obj|
        next unless File.directory?(file)

        project_name = file.split("/").last
        obj << project_name
      end
    end

    def create_repository(url : String, name : String? = nil, mirror_only = false)
      repo = Repository.new url
      project_name = name ? name : repo.mirror_name

      raise RepositoryExistsError.new "Exists Repository: #{project_name}" if reopsitory_stored?(project_name)

      Hpr.logger.info "creating repository in gitlab ... #{@group["name"]}/#{project_name}"

      loop do
        begin
          Hpr.gitlab.create_project project_name, {
            "namespace_id"           => @namespace["id"].to_s,
            "description"            => "Mirror of #{url}",
            "visibility"             => (Hpr.config.gitlab.project_public ? "public" : "private"),
            "issues_enabled"         => Hpr.config.gitlab.project_issue.to_s,
            "wiki_enabled"           => Hpr.config.gitlab.project_wiki.to_s,
            "snippets_enabled"       => Hpr.config.gitlab.project_snippet.to_s,
            "merge_requests_enabled" => Hpr.config.gitlab.project_merge_request.to_s,
          }

          break
        rescue e : Gitlab::Error::BadRequest
          if (message = e.message) && message.includes?("still being deleted")
            sleep 1.seconds
          else
            raise e
          end
        end
      end unless mirror_only

      CloneRepositoryWorker.async.perform repo.url, project_name
    end

    def update_repository(name : String)
      raise NotFoundRepositoryError.new "Not found repository: #{name}" unless reopsitory_stored?(name)

      UpdateRepositoryWorker.async.perform name
    end

    def delete_repository(name : String)
      projects = Hpr.gitlab.group_projects @group["id"].as_i, {"search" => name}
      unless projects.as_a.empty?
        project = projects[0]

        Hpr.logger.info "destroying repository in gitlab ... #{@group["name"]}/#{name}"
        r = Hpr.gitlab.delete_project project["id"].as_i
      end

      DeleteRepositoryWorker.async.perform name
    end

    def delete_repository(all = true)
      list_repositories.each do |name|
        delete_repository name
      end
    end

    def reopsitory_stored?(name)
      Dir.exists?(Utils.repository_path(name))
    end

    private def current_user
      Hpr.gitlab.user
    end

    private def current_group
      Hpr.gitlab.group Hpr.config.gitlab.group_name
    rescue Gitlab::Error::NotFound
      Hpr.gitlab.create_group Hpr.config.gitlab.group_name, Hpr.config.gitlab.group_name
    end

    private def group_namespace
      r = Hpr.gitlab.get "groups/#{Hpr.config.gitlab.group_name}"
      JSON.parse r.body
    end

    def determine_git!
      _, _, success = Utils.run_cmd "which git"
      raise NotFoundGitError.new "Please install git." unless success
    end

    def determine_gitlab_configure!
      raise NotRoleError.new "Please enable create group role." unless @user["can_create_group"].as_bool
      raise NotRoleError.new "Please enable create project role." unless @user["can_create_project"].as_bool

      ssh_keys = Hpr.gitlab.ssh_keys
      raise MissingSSHKeyError.new "Please add ssh key for '#{@user["name"]}' user." if ssh_keys.as_a.empty?
    end

    private def determine_repository_path!
      path = Hpr.config.repository_path
      unless Dir.exists?(path)
        FileUtils.mkdir_p path
      end
    end
  end
end
