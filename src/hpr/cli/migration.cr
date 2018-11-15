class Hpr::Cli
  class Migration < Command
    def run(**args)
      source = args[:source]
      source_path = args[:source_path]
      preview_mode = args[:preview_mode]

      determine_source!(source)
      determine_path!(source_path)

      start_worker
      Terminal.message "migrating #{source} repositories ... #{source_path}"
      find_repositories(source_path) do |name, old_path, new_path|
        Terminal.header name
        status, message = pass?(old_path, new_path)
        unless status
          Terminal.important message
          next
        end

        if preview_mode
          Terminal.verbose "#{old_path} => #{new_path}"
          next
        end

        begin
          copy_repository(old_path, new_path)
          configure_remote(name)
        rescue e : Exception
          Terminal.error "Catched unkown exception, clean for processing sources"
          Terminal.error e.message
          Terminal.error "  #{e.backtrace.join("\n  ")}"
          Hpr.capture_exception(e, "cli")

          FileUtils.rm_rf new_path
          exit
        end
      end

      if preview_mode
        Terminal.important "You are in preview mode, remove `--preview` and run again if check everything is all right."
      else
        Terminal.success "All done, nice job!"
      end
    end

    def copy_repository(old_path, new_path)
      Terminal.message "Coping repository directory"
      FileUtils.cp_r(old_path, new_path)
    end

    def configure_remote(name)
      repo = Hpr::Git::Repo.repository(name)
      project = gitlab_project(repo, name)
      if project
        Terminal.message "Configuring remote of git"
        Hpr::Git::Helper.write_mirror_to_git_config(repo, name, project.as_h["path"].as_s)

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
    end

    private def mirrored?(path)
      Dir.exists?(path)
    end

    private def git_repository?(path)
      Git::Repo.new(path).repo?
    end

    private def pass?(old_path, new_path)
      status = true
      message = ""

      unless File.directory?(old_path) && git_repository?(old_path)
        status = false
        message = "Not git repository, Skip"
      end

      if mirrored?(new_path)
        status = false
        message = "Existed, Skip"
      end

      {status, message}
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

    private def find_repositories(path)
      Dir.glob(File.join(path, "*")) do |source_path|
        name = File.basename(source_path)
        yield name, source_path, repository_path(name)
      end
    end

    private def repository_path(name)
      File.join(repository_path, name)
    end

    private def repository_path
      Hpr.config.repository_path
    end
  end
end

# require "option_parser"
# require "file_utils"
# require "terminal"
# require "halite"
# require "uri"
# require "../../hpr"

# source = "gitlab-mirror"
# source_path = ""
# group_name = Hpr.config.gitlab.group_name
# clean = false

# hpr_endpoint = ""
# hpr_username = ""
# hpr_password = ""

# OptionParser.parse! do |parser|
#   parser.banner = "Usage: hpr-migration [options] path"

#   parser.separator("\nOptions:\n")
# parser.on("-p PATH", "--path PATH", "the path of hpr root directory") { |path| Hpr.config(path) }
# parser.on("-s SOURCE", "--source=SOURCE", "The source of migration came from (avaiable gitlab-mirror only)") { |s| source = s }
# parser.on("--group-name=NAME", "The group name from gitlab-mirror config") { |name| group_name = name }
# parser.on("--clean", "The clean config in gitlab-mirror") { clean = true }
# parser.on("--endpoint=ENDPOINT", "The endpoint of Hpr") { |endpoint| hpr_endpoint = endpoint }
# parser.on("--username=USERNAME", "The endpoint of Hpr") { |username| hpr_username = username }
# parser.on("--password=PASSWORD", "The endpoint of Hpr") { |password| hpr_password = password }
# parser.on("-h", "--help", "Show help") { puts parser; exit }

#   parser.unknown_args do |unknown_args|
#     source_path = unknown_args.first if unknown_args.size > 0
#   end
# end

# if source_path.empty?
#   Terminal.error "Path is empty!"
#   exit
# end

# source_path = File.join(source_path, group_name)
# unless Dir.exists?(source_path)
#   Terminal.error "Path must be directory which was copy from #{source}'s repositories."
#   exit
# end

# repository_path = Hpr.config.repository_path
# unless Dir.exists?(repository_path)
#   FileUtils.mkdir(repository_path)
# end

# halite = Halite::Client.new do
#   if !hpr_username.empty? || !hpr_password.empty?
#     basic_auth hpr_username, hpr_password
#   end
# end

# current_path = Dir.current
# repo_uri = URI.parse(hpr_endpoint)
# repo_uri.path = "/repositories"
# repo_url = repo_uri.to_s

# Dir.glob("#{source_path}/*") do |repo_path|
#   Dir.cd current_path
#   repo_name = File.basename(repo_path)
#   desc_path = File.join(repository_path, repo_name)

#   Terminal.header repo_name
#   if File.directory?(repo_path) && !Dir.exists?(desc_path)
#     Terminal.message " - Coping repository"
#     FileUtils.cp_r(repo_path, desc_path)

#     client = Hpr::Client.new
#     gitlab_project = client.search_gitlab_repository(repo_name)

#     unless gitlab_project
#       Terminal.message " - Create gitlab repository"
#       repo_info = Hpr::Git::Helper.repository_info(repo_name)
#       halite.post repo_url, form: {url: repo_info["url"], name: repo_name, clone: "false"}
#       gitlab_project = client.search_gitlab_repository(repo_name) unless gitlab_project
#     end

#     if gitlab_project
#       Terminal.message " - Configuring git remote"
#       repo = Hpr::Git::Repo.repository(repo_name)
#       Hpr::Git::Helper.write_mirror_to_git_config(repo, repo_name, gitlab_project.as_h["path"].as_s)

#       Terminal.message " - Updating and pushing mirror"
#       halite.put "#{repo_url}/#{repo_name}"
#     else
#       Terminal.important " - Not exists project in gitlab"
#     end
#   else
#     Terminal.important " - Existed, Skip"
#   end
# end
