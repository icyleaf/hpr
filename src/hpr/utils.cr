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
      Dir.cd Utils.repository_path(name)

      Utils.run_cmd "git config credential.helper store"
      Utils.run_cmd "git remote add mirror #{mirror_ssh_url(name, namespace)}"
      Utils.run_cmd "git config --add remote.mirror.push '+refs/heads/*:refs/heads/*'"
      Utils.run_cmd "git config --add remote.mirror.push '+refs/remotes/tags/*:refs/remotes/tags/*'"
      Utils.run_cmd "git config remote.mirror.mirror true"
      Utils.run_cmd "git config hpr.status 'idle'"
      Utils.run_cmd "git config hpr.created '#{Utils.current_datetime}'"
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

      Dir.cd repository_path(name)
      status = run_cmd("git config hpr.status").first.as(String)
      status == "busy"
    end

    def repository_info(name : String)
      Dir.cd repository_path(name)

      # depend on git 2.7.0+
      {
        "name"           => name,
        "url"            => run_cmd("git remote get-url --push origin").first.as(String),
        "mirror_url"     => run_cmd("git remote get-url --push mirror").first.as(String),
        "latest_version" => run_cmd("git describe --abbrev=0 --tags 2>/dev/null").first.as(String),
        "status"         => run_cmd("git config hpr.status").first.as(String),
        "created_at"     => run_cmd("git config hpr.created").first.as(String),
        "updated_at"     => run_cmd("git config hpr.updated").first.as(String),
        "scheduled_at"   => run_cmd("git config hpr.scheduled").first.as(String),
      }
    end

    def mirror_ssh_url(name, namespace : String? = nil)
      gitlab = Hpr.config.gitlab
      gitlab_host = gitlab.endpoint.host
      gitlab_port = (gitlab.ssh_port != 22) ? "#{Hpr.config.gitlab.ssh_port}/" : ""
      namespace ||= name.downcase

      "git@#{gitlab_host}:#{gitlab_port}#{gitlab.group_name}/#{namespace}.git"
    end

    def repository_path?(name : String) : String?
      path = repository_path(name)
      Dir.exists?(path) ? path : nil
    end

    def repository_path(name : String)
      File.join(Hpr.config.repository_path, name)
    end

    def tryable(max_connect = 3, verbose = false, &block)
      count = 1
      loop do
        begin
          Hpr.logger.debug "try ... #{count}" if verbose
          break if count > max_connect
          return yield
          break
        rescue e : Exception
          Hpr.logger.debug " * #{e.class}: #{e.message}"
          count += 1
          sleep 1
        end
      end
    end
  end
end
