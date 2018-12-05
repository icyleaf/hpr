module Hpr
  struct UpdateRepositoryWorker
    include Worker::Base

    def perform(name : String, repository_path : String, schedule_time : Time)
      path = File.join(repository_path, name)
      # Skip when repository id not exists (may be deleted).
      unless Dir.exists? path
        error "repository folder not exists ... #{name}"
        return
      end

      # Skip when repository not exists at gitlab service(deleted remotely)
      # unless project = search_project(name)
      #   error "repository of gitlab not exists ... #{name}"
      #   return
      # end

      model = Model::Repository.find_by! name: name
      repo = Git.new path
      debug "updating from origin ... #{name}"
      model.update! status: "fetching"
      repo.fetch_remote("origin")

      debug "pushing to gitlab ... #{name}"
      model.update! status: "pushing"
      repo.push_remote("hpr")

      model.update! status: "idle", scheduled_at: schedule_time
      set_schedule_time name, repository_path, schedule_time

      # with_syncing project, name do
      #   repo = Git.new File.join(repository_path, name)
      #   # repo.set_config("hpr.status", "fetching")
      #   info "updating from origin ... #{name}"
      #   repo.fetch_remote("origin")

      #   info "pushing to gitlab ... #{name}"
      #   # repo.set_config("hpr.status", "pushing")
      #   repo.push_remote("hpr")
      #   # repo.set_config("hpr.updated", current_datetime)
      #   # repo.set_config("hpr.status", "idle")
      # end

      # # update_schedule(name)
    end

    private def with_syncing(project, name)
      flag = "[Syncing]"
      description = project["description"].to_s
      description = if description.empty?
                      repo_info = repository_info(name)
                      "Mirror of #{repo_info["url"]}"
                    else
                      description.gsub(flag, "").strip
                    end
      update_project_description(project, "#{flag} #{description}")

      yield

      update_project_description(project, description)
    end

    private def update_project_description(project, description)
      Hpr.gitlab.edit_project(project["id"].as_i, {"description" => description})
    end

    private def search_project(name) : JSON::Any?
      projects = Hpr.gitlab.projects({"search" => name})
      selected = projects.as_a.select { |p| p["name"] == name }
      return if selected.empty?

      selected.first
    end
  end
end
