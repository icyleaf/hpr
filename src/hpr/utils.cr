module Hpr
  module Utils
    extend self

    def user_error!(message)
      Hpr.logger.error message
      raise Hpr::Error.new message
    end

    def current_datetime
      Time.now.to_s("%F %T %z")
    end

    def project_name(url : String)
      repo = Repository.new url
      repo.mirror_name
    end

    def write_mirror_to_git_config(name, namespace : String? = nil)
      path_to_repo(name) do
        Utils.run_cmd "git config credential.helper store"
        Utils.run_cmd "git remote add hpr #{mirror_ssh_url(name, namespace)}"
        Utils.run_cmd "git config --add remote.hpr.push '+refs/heads/*:refs/heads/*'"
        Utils.run_cmd "git config --add remote.hpr.push '+refs/tags/*:refs/tags/*'"
        Utils.run_cmd "git config remote.hpr.mirror true"
        Utils.run_cmd "git config hpr.status 'idle'"
        Utils.run_cmd "git config hpr.created '#{Utils.current_datetime}'"
      end
    end

    def run_cmd(command : String)
      process = Process.new(command, shell: true, output: Process::Redirect::Pipe, error: Process::Redirect::Pipe)
      output = process.output.gets_to_end.strip
      error = process.error.gets_to_end
      status = process.wait

      [output, error, status.success?]
    end

    def repository_cloning?(name : String)
      repository_path?(name) && !File.exists?(File.join(repository_path(name), "packed-refs"))
    end

    def repository_updating?(name : String)
      return false unless repository_path?(name)

      path_to_repo(name) do
        status = run_cmd("git config hpr.status").first.as(String)
        status == "pushing"
      end
    end

    def repository_info(name : String)
      path_to_repo(name) do
        # depend on git 2.7.0+
        {
          "name"           => name,
          "url"            => run_cmd("git remote get-url --push origin").first.as(String),
          "mirror_url"     => run_cmd("git remote get-url --push hpr").first.as(String),
          "latest_version" => run_cmd("git describe --abbrev=0 --tags 2>/dev/null").first.as(String),
          "status"         => run_cmd("git config hpr.status").first.as(String),
          "created_at"     => run_cmd("git config hpr.created").first.as(String),
          "updated_at"     => run_cmd("git config hpr.updated").first.as(String),
          "scheduled_at"   => run_cmd("git config hpr.scheduled").first.as(String),
        }
      end
    end

    def mirror_ssh_url(name, namespace : String? = nil)
      gitlab = Hpr.config.gitlab
      gitlab_host = gitlab.endpoint.host
      gitlab_port = (gitlab.ssh_port != 22) ? "#{Hpr.config.gitlab.ssh_port}/" : ""
      namespace ||= name.downcase

      "git@#{gitlab_host}:#{gitlab_port}#{gitlab.group_name}/#{namespace}.git"
    end

    def path_to_repo(name)
      Dir.cd(repository_path(name)) do
        yield
      end
    end

    def path_to_repo

    end

    def repository_path?(name : String) : String?
      path = repository_path(name)
      Dir.exists?(path) ? path : nil
    end

    def repository_path(name : String)
      File.join(Hpr.config.repository_path, name)
    end
  end
end
