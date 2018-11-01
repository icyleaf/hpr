module Hpr
  struct UpdateRepositoryWorker
    include Sidekiq::Worker

    def perform(name : String)
      repository_path = Utils.repository_path(name)
      # Skip when repository id not exists (may be deleted).
      unless Dir.exists?(repository_path)
        Hpr.logger.error "repository folder not exists ... #{name}"
        return
      end

      # Sikp when repository not exists at gitlab service(deleted remotely)
      unless project = search_project(name)
        Hpr.logger.error "repository of gitlab not exists ... #{name}"
        return
      end

      description = project["description"].to_s
      if description.empty?
        repo_info = Utils.repository_info(name)
        description = "Mirror of #{repo_info["url"]}"
      end
      update_project_description(project, "[Syncing] #{description}")

      Dir.cd repository_path
      Hpr.logger.info "updating from origin ... #{name}"
      Utils.run_cmd "git config hpr.status 'fetching from origin'"
      Utils.run_cmd "git fetch origin"

      Hpr.logger.info "pushing to mirror ... #{name}"
      Utils.run_cmd "git push hpr"
      Utils.run_cmd "git config hpr.status 'pushing to hpr'"
      Utils.run_cmd "git config hpr.updated '#{Utils.current_datetime}'"
      Utils.run_cmd "git config hpr.status 'idle'"

      update_project_description(project, description)

      update_schedule(name)
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

    private def update_schedule(name : String)
      schedule_in = Hpr.config.schedule_in
      UpdateRepositoryWorker.async.perform_in(schedule_in, name)

      Dir.cd Utils.repository_path(name)
      Utils.run_cmd "git config hpr.scheduled '#{(schedule_in.from_now).to_s("%F %T %z")}'"
    end
  end
end
