module Hpr::Git
  module Helper
    extend self

    def current_datetime
      Time.now.to_s("%F %T %z")
    end

    def project_name(url : String)
      repo = URLParser.new url
      repo.mirror_name
    end

    def write_mirror_to_git_config(repo, name, namespace : String? = nil)
      repo = Git::Repo.repository(name)
      repo.set_config("credential.helper", "store")
      repo.add_remote("hpr", mirror_ssh_url(name, namespace))
      repo.add_config("remote.hpr.push", "+refs/heads/*:refs/heads/*")
      repo.add_config("remote.hpr.push", "+refs/tags/*:refs/tags/*")
      repo.set_config("remote.hpr.mirror", true)
      repo.set_config("hpr.status", "idle")
      repo.set_config("hpr.created", "#{current_datetime}")
    end

    def repository_updating?(name : String)
      return false unless Git::Repo.repository_path?(name)

      repo = Git::Repo.repository(name)
      repo.config("hpr.status") == "pushing"
    end

    def repository_info(name : String)
      repo = Git::Repo.repository(name)
      {
        "name"           => name,
        "url"            => repo.remote("origin").pull_url,
        "mirror_url"     => repo.remote("hpr").push_url,
        "latest_version" => repo.latest_tag,
        "status"         => repo.config("hpr.status"),
        "created_at"     => repo.config("hpr.created"),
        "updated_at"     => repo.config("hpr.updated", ""),
        "scheduled_at"   => repo.config("hpr.scheduled", ""),
      }
    end

    def mirror_ssh_url(name, namespace : String? = nil)
      gitlab = Hpr.config.gitlab
      gitlab_host = gitlab.endpoint.host
      gitlab_port = (gitlab.ssh_port != 22) ? "#{Hpr.config.gitlab.ssh_port}/" : ""
      namespace ||= name.downcase

      "git@#{gitlab_host}:#{gitlab_port}#{gitlab.group_name}/#{namespace}.git"
    end
  end
end
