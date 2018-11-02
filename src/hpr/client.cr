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

    def search_repositories(query : String)
      query = query.downcase
      list_repositories.each_with_object([] of String) do |name, obj|
        obj << name if name.downcase.includes?(query)
      end
    end

    def create_repository(url : String, name : String? = nil, create = true, clone = true)
      repo = Repository.new url
      project_name = (name && !name.empty?) ? name : repo.mirror_name

      project = if create
                  create_gitlab_repository(project_name, url)
                else
                  search_gitlab_repository(project_name)
                end

      Utils.user_error! "Not found gitlab project: #{project_name}" unless project

      Utils.user_error! "Exists Repository: #{project_name}" if clone && reopsitory_stored?(project_name)
      CloneRepositoryWorker.async.perform repo.url, project_name, project["path"].as_s if clone
    end

    def update_repository(name : String)
      Utils.user_error! "repository not exists ... #{name}" unless reopsitory_stored?(name)
      UpdateRepositoryWorker.async.perform name
    end

    def delete_repository(name : String)
      if project = search_gitlab_repository(name)
        Hpr.logger.info "destroying project ... #{@group["name"]}/#{name}"
        r = Hpr.gitlab.delete_project project["id"].as_i
      end

      DeleteRepositoryWorker.async.perform name
    end

    def delete_repository(all = true)
      list_repositories.each do |name|
        delete_repository name
      end
    end

    def search_gitlab_repository(name)
      projects = Hpr.gitlab.project_search(name)
        .as_a
        .select { |project| project.as_h["namespace"].as_h["id"] == @group["id"] }

      return projects[0] unless projects.empty?
    end

    def create_gitlab_repository(name, url)
      Hpr.logger.info "creating gitlab repository ... #{@group["name"]}/#{name}"

      loop do
        begin
          return Hpr.gitlab.create_project name, {
            "namespace_id"           => @namespace["id"].to_s,
            "path"                   => name,
            "description"            => "Mirror of #{url}",
            "visibility"             => (Hpr.config.gitlab.project_public ? "public" : "private"),
            "issues_enabled"         => Hpr.config.gitlab.project_issue.to_s,
            "wiki_enabled"           => Hpr.config.gitlab.project_wiki.to_s,
            "snippets_enabled"       => Hpr.config.gitlab.project_snippet.to_s,
            "merge_requests_enabled" => Hpr.config.gitlab.project_merge_request.to_s,
          }
        rescue e : Gitlab::Error::BadRequest
          if (message = e.message) && message.includes?("still being deleted")
            sleep 1.seconds
          else
            raise e
          end
        end
      end
    end

    private def reopsitory_stored?(name)
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
