require "../../core/git/helper"

class Hpr::Cli
  class Migration < Command
    include Git::Helper

    def run(**args)
      source = args[:source]
      source_path = args[:source_path]
      preview_mode = args[:preview_mode]

      determine_source!(source)
      determine_path!(source_path)

      start_worker

      has_exception = false
      FileUtils.mkdir_p(repository_path)
      Terminal.message "migrating #{source} repositories ... #{source_path}"
      find_repositories(source_path) do |name, old_path, new_path|
        message = fail?(old_path, new_path)

        if preview_mode
          status = message ? "[SKIP] #{message}".colorize(:yellow) : "[OK]".colorize(:green)
          Terminal.verbose "#{name.colorize(:magenta)} #{status}"
          next
        end

        Terminal.header name
        if message
          Terminal.important message
          next
        end

        begin
          copy_repository(old_path, new_path)
          configure_remote(name)
        rescue ex : Exception
          has_exception = true
          Terminal.error "Catched unkown exception, clean for processing sources"
          Hpr.capture_exception(ex, "cli", print_output_error: true)

          FileUtils.rm_rf new_path
          exit
        end
      end

      if preview_mode
        Terminal.message "You are in preview mode, remove `--preview` and run again if check everything is all right."
      else
        Terminal.success "All done, nice job!" unless has_exception
      end
    end

    def copy_repository(old_path, new_path)
      Terminal.message "Coping repository directory"
      FileUtils.cp_r(old_path, new_path)
    end

    def configure_remote(name)
      repo = Hpr::Git.new(repository_path(name))
      project = gitlab_project(repo, name)
      if project
        Terminal.message "Configuring remote of git"
        write_mirror_to_git_config(repo, project.as_h["ssh_url_to_repo"].as_s)

        unless client.has_repository?(name)
          url = repo.remote("origin").pull_url
          mirror_url = repo.remote("hpr").push_url
          Terminal.message "Recording repository to database"
          Model::Repository.create name: name, url: url, mirror_url: mirror_url
        end

        Terminal.message "Fetching origin and pushing gitlab"
        client.update_repository(name)
        wait_updating(name)
      else
        Terminal.error "Can not create gitlab project"
      end
    end

    def gitlab_project(repo, name)
      project = search_project(name)
      unless project
        Terminal.message "Create gitlab project"
        client.create_repository(repo.remote("origin").pull_url, name, clone: false)
        project = search_project(name)
      end

      project
    end

    private def search_project(name)
      client.search_gitlab_repository(name)
    rescue
      nil
    end

    private def find_repositories(path)
      Dir.glob(File.join(File.expand_path(path), "*")).sort.each do |source_path|
        name = File.basename(source_path)
        yield name, source_path, repository_path(name)
      end
    end

    private def fail?(old_path, new_path)
      return "Not git repository" unless File.directory?(old_path) && git_repository?(old_path)
      return "Repositroy existed" if mirrored?(new_path)
    end

    private def mirrored?(path)
      Dir.exists?(path)
    end

    private def git_repository?(path)
      Git.new(path).repo?
    end

    private def determine_source!(source)
      unless source == "gitlab-mirrors"
        Terminal.error "Sorry, gitlab-mirrors support only for now: https://github.com/samrocketman/gitlab-mirrors"
        exit
      end
    end

    private def determine_path!(source_path)
      unless Dir.exists?(source_path)
        Terminal.error "Source path was not exists in #{source_path}"
        exit
      end
    end

    private def repository_path(name)
      File.join(repository_path, name)
    end

    private def repository_path
      @config.repository_path
    end
  end
end
