module Hpr
  struct CloneRepositoryJob < Faktory::Job
    arg url : String
    arg name : String
    arg config : Config

    def perform
      clone!
      update!
    end

    private def clone!
      clone_repository
      setting_mirror_settings
    end

    private def clone_repository
      repository_path = config.repository_path
      Dir.cd repository_path

      Utils.run_cmd "git clone --mirror #{url} #{name}"
    end

    private def setting_mirror_settings
      Dir.cd File.join(config.repository_path, name)
      Utils.run_cmd "git config credential.helper store",
                    "git remote add downstream #{downstream_url}",
                    "git config --add remote.downstream.push '+refs/heads/*:refs/heads/*'",
                    "git config --add remote.downstream.push '+refs/remotes/tags/*:refs/remotes/tags/*'",
                    "git config remote.downstream.mirror true"
    end

    private def downstream_url
      gitlab_url = Utils.gitlab_url config
      "#{gitlab_url}/#{config.gitlab.group_name}/#{name}.git"
    end

    private def update!
      UpdateRepositoryJob.perform_async(name, config)
    end
  end
end
