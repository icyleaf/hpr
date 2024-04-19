# frozen_string_literal: true

require 'gitlab'
require 'fileutils'

module Hpr
  # Hpr Client
  class Client
    def initialize
      determine_repository_path!
      determine_gitlab_configure!
    end

    def list_repositories(current_page = 1, per_page = 50)
      offset = (current_page - 1) * per_page
      Repository.offset(offset).limit(per_page).order(id: :desc)
    end

    def repository(name)
      Repository.find_by(name: name)
    end

    def create_repository(url, name = nil, create = true, clone = true)
      git_url = Helper.git_url_parse url
      name = name && !name.empty? ? name : git_url.mirror_name

      repository = Repository.find_by(url: url)
      raise RepositoryExistsError, "Exists Repository #{name} with url: #{url}" if repository

      project = find_or_create_gitlab_repository name, url, create
      raise NotFoundGitlabProjectError, "Not found Gitlab project #{name}" unless project

      # create repository model and start clone job
      CloneWorker.perform_async(name, url, project.ssh_url_to_repo, project.id) if clone
    end

    def update_repository(name)
      UpdateWorker.perform_async name
    end

    def destory_repository(name)
      repository = Repository.find_by(name: name)
      gitlab_project_id = if repository
                            project_id = repository.gitlab_project_id
                            repository.destroy
                            project_id
                          elsif (project = search_gitlab_repository(name))
                            project.id
                          end

      begin
        gitlab.delete_project gitlab_project_id if gitlab_project_id && gitlab.project(gitlab_project_id)
      rescue Gitlab::Error::NotFound
        # do nothing
      end

      DestroyWorker.perform_async name
    end

    def search_repositories(query)
      Repository.where("name LIKE '%#{query}%'")
    end

    def total_repositories
      Repository.count
    end

    private

    def find_or_create_gitlab_repository(name, url, create = false)
      create ? create_gitlab_repository(name, url) : search_gitlab_repository(name)
    end

    def create_gitlab_repository(name, url)
      loop do
        begin
          return gitlab.create_project name, namespace_id: group_namespace.id,
                                             path: name,
                                             description: "Mirror of #{url}",
                                             visibility: (Hpr::Configuration.gitlab.project_public ? 'public' : 'private'),
                                             issues_enabled: Hpr::Configuration.gitlab.project_issue,
                                             wiki_enabled: Hpr::Configuration.gitlab.project_wiki,
                                             snippets_enabled: Hpr::Configuration.gitlab.project_snippet,
                                             merge_requests_enabled: Hpr::Configuration.gitlab.project_merge_request
        rescue Gitlab::Error::BadRequest => e
          raise e unless (message = e.message) && message.include?('still being deleted')

          sleep 1
        end
      end
    end

    def search_gitlab_repository(name)
      projects = gitlab.project_search(name).select { |project| project.namespace.id == current_group.id }
      return if projects.empty?

      projects[0]
    end

    def determine_repository_path!
      path = Hpr::Configuration.repository_path
      FileUtils.mkdir_p(path) unless Dir.exist?(path)
    end

    def determine_gitlab_configure!
      raise NotRoleError, 'Please enable create group role.' unless current_user.can_create_group
      raise NotRoleError, 'Please enable create project role.' unless current_user.can_create_project
      raise MissingSSHKeyError, "Please add ssh key for `#{current_user.name}` user." if gitlab.ssh_keys.empty?
    end

    def current_user
      @current_user ||= gitlab.user
      @current_user
    end

    def current_group
      @current_group ||= gitlab.group Hpr::Configuration.gitlab.group_name
    rescue Gitlab::Error::Error
      raise 'Please enable create group role.' unless current_user.can_create_group

      group_name = Hpr::Configuration.gitlab.group_name
      visibility = Hpr::Configuration.gitlab.project_public ? 'public' : 'private'
      @current_group = gitlab.create_group group_name, group_name, visibility: visibility
    end

    def group_namespace
      gitlab.group(Hpr::Configuration.gitlab.group_name)
    end

    def gitlab
      @gitlab ||= Gitlab.client(
        endpoint: Hpr::Configuration.gitlab.endpoint,
        private_token: Hpr::Configuration.gitlab.private_token
      )
    end
  end
end
