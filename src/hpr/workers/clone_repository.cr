module Hpr
  struct CloneRepositoryWorker
    include Worker::Base

    def perform(url : String, name : String, namespace : String)
      repo = Git::Repo.repository(name)
      if repo.exists?
        error "Repository #{name} was exists with #{url}"
        return
      end

      clone_repository(repo, url)
      setting_mirror_settings_and_push(repo, name, namespace)
      update_schedule(name)
    end

    private def clone_repository(repo, url)
      name = File.basename(repo.path)
      info "cloning #{url} ... #{name}"
      repo.clone(url, mirror: true)
    end

    private def setting_mirror_settings_and_push(repo, name, namespace)
      write_mirror_to_git_config(repo, name, namespace)

      # Push
      info "pushing to gitlab ... #{name}"
      repo.set_config("hpr.status", "pushing")
      repo.push_remote("hpr")
      repo.set_config("hpr.status", "idle")
      repo.set_config("hpr.updated", "#{current_datetime}")
    end
  end
end
