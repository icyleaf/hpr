require "gitlab"
require "json"

module Hpr
  class Client
    @gitlab : Gitlab::Client
    @user : JSON::Any
    @group : JSON::Any
    @namespace : JSON::Any

    def initialize(@config : Hpr::Config)
      @gitlab = Gitlab.client @config.gitlab.endpoint, @config.gitlab.private_token
      @user = current_user
      @group = current_group
      @namespace = group_namespace

      determine_repository_path!
      determine_gitlab_configure!
    end

    def total_repositories
      Model::Repository.count
    end

    def list_repositories(current_page = 1, per_page = 50)
      offset = (current_page - 1) * per_page
      Model::Repository.offset(offset).limit(per_page).select
    end

    def repository(name)
      Model::Repository.find_by!(name: name)
    end

    def search_repositories(query : String)
      Model::Repository.where(name: query.downcase).select
    end

    def create_repository(url : String, name : String? = nil, create = true, clone = true)
      url_parser = Git::URLParser.new url
      name = (name && !name.empty?) ? name : url_parser.mirror_name

      raise RepositoryExistsError.new "Exists Repository #{name}" if Model::Repository.find_by url: url

      project = find_or_create_gitlab_repo name, url, create
      raise NotFoundGitlabProjectError.new("Not found gitlab project #{name}") unless project

      mirror_url = project["ssh_url_to_repo"].as_s
      CloneRepositoryWorker.async.perform name, url, mirror_url, @config.repository_path, @config.schedule_in.from_now if clone
    end

    def update_repository(name : String)
      raise NotFoundRepositoryError.new("Repository not exists #{name}") unless repo = Model::Repository.find_by(name: name)
      UpdateRepositoryWorker.async.perform name, @config.repository_path, @config.schedule_in.from_now
    end

    def delete_repository(name : String)
      raise NotFoundRepositoryError.new("Repository not exists #{name}") unless repo = Model::Repository.find_by(name: name)

      repo.destroy
      if project = search_gitlab_repository(name)
        @gitlab.delete_project project["id"].as_i
      end

      DeleteRepositoryWorker.async.perform name, @config.repository_path
    end

    def delete_repository(*, all = true)
      Model::Repository.all.each do |repo|
        begin
          name = repo.name
          delete_repository name
        rescue e : NotFoundRepositoryError
          next
        end
      end
    end

    def search_gitlab_repository(name)
      projects = @gitlab.project_search(name)
        .as_a
        .select { |project| project.as_h["namespace"].as_h["id"] == @group["id"] }

      return projects[0] unless projects.empty?
    end

    def create_gitlab_repository(name, url)
      loop do
        begin
          return @gitlab.create_project name, {
            "namespace_id"           => @namespace["id"].to_s,
            "path"                   => name,
            "description"            => "Mirror of #{url}",
            "visibility"             => (@config.gitlab.project_public ? "public" : "private"),
            "issues_enabled"         => @config.gitlab.project_issue.to_s,
            "wiki_enabled"           => @config.gitlab.project_wiki.to_s,
            "snippets_enabled"       => @config.gitlab.project_snippet.to_s,
            "merge_requests_enabled" => @config.gitlab.project_merge_request.to_s,
          }
        rescue e : Gitlab::Error::BadRequest
          raise e unless (message = e.message) && message.includes?("still being deleted")
          sleep 1.seconds
        end
      end
    end

    private def find_or_create_gitlab_repo(name, url, create)
      if create
        create_gitlab_repository(name, url)
      else
        search_gitlab_repository(name)
      end
    end

    private def current_user
      @gitlab.user
    end

    private def current_group
      @gitlab.group @config.gitlab.group_name
    rescue Gitlab::Error::NotFound
      raise NotRoleError.new "Please enable create group role." unless @user["can_create_group"].as_bool
      @gitlab.create_group @config.gitlab.group_name, @config.gitlab.group_name
    end

    private def group_namespace
      @gitlab.get("groups/#{@config.gitlab.group_name}").parse
    end

    def determine_gitlab_configure!
      raise NotRoleError.new "Please enable create project role." unless @user["can_create_project"].as_bool

      ssh_keys = @gitlab.ssh_keys
      raise MissingSSHKeyError.new "Please add ssh key for '#{@user["name"]}' user." if ssh_keys.as_a.empty?
    end

    private def determine_repository_path!
      path = @config.repository_path
      FileUtils.mkdir_p(path) unless Dir.exists?(path)
    end

    private def repository_path?(name : String)
      path = repository_path(name)
      Dir.exists?(path) ? path : nil
    end

    private def repository_path(name)
      File.join(@config.repository_path, name)
    end

    private def mirror_ssh_url(name, namespace : String? = nil)
      gitlab = @config.gitlab
      gitlab_host = gitlab.endpoint.host
      gitlab_port = (gitlab.ssh_port != 22) ? "#{Hpr.config.gitlab.ssh_port}/" : ""
      namespace ||= name.downcase

      "git@#{gitlab_host}:#{gitlab_port}#{gitlab.group_name}/#{namespace}.git"
    end
  end
end
