module Hpr
  struct CloneRepositoryJob < Faktory::Job
    arg url : String
    arg name : String

    def perform
      clone_and_push!
    end

    private def clone_and_push!
      clone_repository
      setting_mirror_settings_and_push
    end

    private def clone_repository
      repository_path = Hpr.config.repository_path
      Dir.cd repository_path

      Utils.run_cmd "git clone --mirror #{url} #{name}"
    end

    private def setting_mirror_settings_and_push
      Dir.cd Utils.repository_path(name)
      Utils.run_cmd "git config credential.helper store",
                    "git remote add mirror #{mirror_url}",
                    "git config --add remote.mirror.push '+refs/heads/*:refs/heads/*'",
                    "git config --add remote.mirror.push '+refs/remotes/tags/*:refs/remotes/tags/*'",
                    "git config remote.mirror.mirror true",
                    "git push mirror"
    end

    private def mirror_url
      gitlab_url = Utils.gitlab_url Hpr.config
      "#{gitlab_url}/#{Hpr.config.gitlab.group_name}/#{name}.git"
    end
  end
end
