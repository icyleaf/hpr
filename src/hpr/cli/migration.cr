require "option_parser"
require "file_utils"
require "halite"
require "uri"
require "../../hpr"

source = "gitlab-mirror"
source_path = ""
group_name = Hpr.config.gitlab.group_name
clean = false

hpr_endpoint = ""
hpr_username = ""
hpr_password = ""

OptionParser.parse! do |parser|
  parser.banner = "Usage: hpr-migration [options] path"

  parser.separator("\nOptions:\n")
  parser.on("-f FILE", "--file FILE", "the path of hpr.json config file") { |path| Hpr.reload_config(path) }
  parser.on("-s SOURCE", "--source=SOURCE", "The source of migration came from (avaiable gitlab-mirror only)") { |s| source = s }
  parser.on("--group-name=NAME", "The group name from gitlab-mirror config") { |name| group_name = name }
  parser.on("--clean", "The clean config in gitlab-mirror") { clean = true }
  parser.on("--endpoint=ENDPOINT", "The endpoint of Hpr") { |endpoint| hpr_endpoint = endpoint }
  parser.on("--username=USERNAME", "The endpoint of Hpr") { |username| hpr_username = username }
  parser.on("--password=PASSWORD", "The endpoint of Hpr") { |password| hpr_password = password }
  parser.on("-h", "--help", "Show help") { puts parser; exit }

  parser.unknown_args do |unknown_args|
    source_path = unknown_args.first if unknown_args.size > 0
  end
end

if source_path.empty?
  puts "Path is empty!"
  exit
end

source_path = File.join(source_path, group_name)
unless Dir.exists?(source_path)
  puts "Path must be directory which was copy from #{source}'s repositories."
  exit
end

repository_path = Hpr.config.repository_path
unless Dir.exists?(repository_path)
  FileUtils.mkdir(repository_path)
end

halite = Halite::Client.new do
  if !hpr_username.empty? || !hpr_password.empty?
    basic_auth hpr_username, hpr_password
  end
end

current_path = Dir.current
repo_uri = URI.parse(hpr_endpoint)
repo_uri.path = "/repositories"
repo_url = repo_uri.to_s

Dir.glob("#{source_path}/*") do |repo_path|
  Dir.cd current_path
  repo_name = File.basename(repo_path)
  desc_path = File.join(repository_path, repo_name)

  puts "* #{repo_name}"
  if File.directory?(repo_path) && !Dir.exists?(desc_path)
    puts " - Coping repository"
    FileUtils.cp_r(repo_path, desc_path)

    client = Hpr::Client.new
    gitlab_project = client.search_gitlab_repository(repo_name)

    unless gitlab_project
      puts " - Create gitlab repository"
      repo_info = Hpr::Utils.repository_info(repo_name)
      halite.post repo_url, form: {url: repo_info["url"], name: repo_name, clone: "false"}
      gitlab_project = client.search_gitlab_repository(repo_name) unless gitlab_project
    end

    if gitlab_project
      puts " - Configuring git remote ..."
      Hpr::Utils.write_mirror_to_git_config(repo_name, gitlab_project.as_h["path"].as_s)

      puts " - Updating and pushing mirror"
      halite.put "#{repo_url}/#{repo_name}"
    else
      puts " - Not exists project in gitlab"
    end
  else
    puts " - Existed, Skip"
  end
end
