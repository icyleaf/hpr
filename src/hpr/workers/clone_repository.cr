module Hpr
  struct CloneRepositoryWorker
    include Worker::Base

    def perform(url : String, name : String, namespace : String)
      if Git::Repo.repository_path?(name)
        error "Repository #{name} was exists with #{url}"
        return
      end

      repo = Git::Repo.new(Hpr.config.repository_path)
      clone_repository(repo, url, name)
      setting_mirror_settings_and_push(repo, name, namespace)
      update_schedule(name)
    end

    private def clone_repository(repo, url, name)
      info "cloning #{url} ... #{name}"
      repo.clone(url, name, mirror: true)
    end

    private def setting_mirror_settings_and_push(repo, name, namespace)
      Utils.write_mirror_to_git_config(repo, name, namespace)

      # Push
      info "pushing to gitlab ... #{name}"
      repo.set_config("hpr.status", "pushing")
      repo.push_remote("hpr")
      repo.set_config("hpr.status", "idle")
      repo.set_config("hpr.updated", "#{Utils.current_datetime}")
    end
  end
end
