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
      # Clone
      Utils.run_cmd "git config credential.helper store"
      Utils.run_cmd "git remote add mirror #{mirror_ssh_url(name)}"
      Utils.run_cmd "git config --add remote.mirror.push '+refs/heads/*:refs/heads/*'"
      Utils.run_cmd "git config --add remote.mirror.push '+refs/remotes/tags/*:refs/remotes/tags/*'"
      Utils.run_cmd "git config remote.mirror.mirror true"
      Utils.run_cmd "git config hpr.status 'idle'"
      Utils.run_cmd "git config hpr.created '#{Utils.current_datetime}'"

      # Push
      Utils.run_cmd "git push mirror"
      Utils.run_cmd "git config hpr.status 'busy'"
      Utils.run_cmd "git config hpr.updated '#{Utils.current_datetime}'"
      Utils.run_cmd "git config hpr.status 'idle'"
    end

    private def update_schedule(url, name)
      schedule_in = Hpr.config.schedule_in
      UpdateRepositoryWorker.async.perform_in(schedule_in, name)

      Dir.cd Utils.repository_path(name)
      Utils.run_cmd "git config hpr.scheduled '#{(schedule_in.from_now).to_s("%F %T %z")}'"
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
