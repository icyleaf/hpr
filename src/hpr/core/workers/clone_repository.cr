module Hpr
  struct CloneRepositoryWorker
    include Worker::Base

    def perform(name : String, url : String, mirror_url : String, repository_path : String, schedule_time : Time)
      model = Model::Repository.create name: name, url: url, mirror_url: mirror_url

      path = File.join repository_path, name
      repo = Hpr::Git.new path
      if repo.exists?
        error "Repository directory #{name} was exists"
        return
      end

      debug "cloning #{url} ... #{name}"
      model.update! status: "cloning"
      repo.clone url, mirror: true

      debug "writing remote config to git ... #{name}"
      write_mirror_to_git_config repo, mirror_url

      debug "pushing to gitlab ... #{name}"
      model.update! status: "pushing"
      repo.push_remote "hpr"

      model.update! status: "idle", scheduled_at: schedule_time
      set_schedule_time name, repository_path, schedule_time
    end
  end
end



