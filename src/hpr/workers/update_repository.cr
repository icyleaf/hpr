module Hpr
  struct UpdateRepositoryWorker
    include Sidekiq::Worker

    def perform(name : String)
      repository_path = Utils.repository_path(name)
      # Skip when repository id not exists (may be deleted).
      return unless Dir.exists?(repository_path)

      # Sikp when repository not exists at gitlab service(deleted remotely)
      return unless project = search_project(name)

      description = project["description"].to_s
      update_project_description(project, "[Syncing] #{description}")

      Dir.cd repository_path
      Utils.run_cmd "git config hpr.status 'busy'"
      Utils.run_cmd "git fetch origin"
      Utils.run_cmd "git push mirror"
      Utils.run_cmd "git config hpr.status 'idle'"

      update_project_description(project, description)

      update_schedule(name)
    end

    private def update_project_description(project, description)
      Hpr.gitlab.edit_project(project["id"].as_i, {"description" => description})
    end

    private def search_project(name) : JSON::Any?
      projects = Hpr.gitlab.projects({"search" => name})
      selected = projects.select {|p|p["name"] == name}
      return if selected.empty?

      selected.first
    end

    private def update_schedule(name : String)
      scheduled = Time::Span.new(0, 0, Hpr.config.schedule)
      UpdateRepositoryWorker.async.perform_in(scheduled, name)

      Dir.cd Utils.repository_path(name)
      Utils.run_cmd "git config hpr.scheduled '#{(Time.now + scheduled).to_s("%F %T %z")}'"
    end
  end
end
