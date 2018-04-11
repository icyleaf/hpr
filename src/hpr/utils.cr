module Hpr
  module Utils
    extend self

    def current_datetime
      Time.now.to_s("%F %T %z")
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

    def repository_path?(name : String) : String?
      path = repository_path(name)
      Dir.exists?(path) ? path : nil
    end

    def repository_path(name : String)
      File.join(Hpr.config.repository_path, name)
    end

    def repository_info(name : String)
      Dir.cd repository_path(name)
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
