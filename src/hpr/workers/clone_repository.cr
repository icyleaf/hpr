module Hpr
  struct CloneRepositoryWorker
    include Sidekiq::Worker

    def perform(url : String, name : String)
      clone_and_push!(url, name)
    end

    private def clone_and_push!(url, name)
      clone_repository(url, name)
      setting_mirror_settings_and_push(url, name)
      update_schedule(url, name)
    end

    private def clone_repository(url, name)
      repository_path = Hpr.config.repository_path
      Dir.cd repository_path

      Utils.run_cmd "git clone --mirror #{url} #{name}"
    end

    private def setting_mirror_settings_and_push(url, name)
      Dir.cd Utils.repository_path(name)
      Utils.run_cmd "git config credential.helper store",
                    "git remote add mirror #{mirror_ssh_url(name)}",
                    "git config --add remote.mirror.push '+refs/heads/*:refs/heads/*'",
                    "git config --add remote.mirror.push '+refs/remotes/tags/*:refs/remotes/tags/*'",
                    "git config remote.mirror.mirror true",
                    "git config hpr.status 'idle'",
                    "git config hpr.created '#{Utils.current_datetime}'",
                    "git push mirror",
                    "git config hpr.status 'busy'",
                    "git config hpr.updated '#{Utils.current_datetime}'",
                    "git config hpr.status 'idle'"
    end

    private def update_schedule(url, name)
      # scheduled = Time.now + Time::Span.new(0, 0, Hpr.config.schedule)
      # UpdateRepositoryWorker.async do |options|
      #   options.perform_at scheduled, name
      # end.perform(name)

      # Dir.cd Utils.repository_path(name)
      # Utils.run_cmd "git config hpr.scheduled '#{scheduled.to_s("%F %T %z")}'"
    end

    private def mirror_ssh_url(name)
      gitlab_host = Hpr.config.gitlab.endpoint.host
      gitlab_port = if Hpr.config.gitlab.ssh_port != 22
        "#{Hpr.config.gitlab.ssh_port}/"
      else
        ""
      end

      "git@#{gitlab_host}:#{gitlab_port}#{Hpr.config.gitlab.group_name}/#{name.downcase}.git"
    end
  end
end
