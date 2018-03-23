module Hpr
  module Utils
    extend self

    def current_datetime
      Time.now.to_s("%F %T %z")
    end

    def run_cmd(*commands, echo = false)
      commands.each_with_object([] of String) do |command, obj|
        Hpr.log.debug "$ #{command}" if echo
        obj << `#{command}`.strip
      end
    end

    def repository_path(name : String)
      File.join(Hpr.config.repository_path, name)
    end

    def repository_path?(name : String) : String?
      path = repository_path(name)
      Dir.exists?(path) ? path : nil
    end

    def repository_info(name : String)
      Dir.cd repository_path(name)
      info = Utils.run_cmd "git remote get-url --push origin",
                           "git remote get-url --push mirror",
                           "git describe --abbrev=0 --tags 2>/dev/null",
                           "git config hpr.status",
                           "git config hpr.created",
                           "git config hpr.updated",
                           "git config hpr.scheduled"
      {
        "name" => name,
        "url" => info[0],
        "mirror_url" => info[1],
        "latest_version" => info[2],
        "status" => info[3],
        "created_at" => info[4],
        "updated_at" => info[5],
        "scheduled_at" => info[6],
      }
    end

    def tryable(max_connect = 3, verbose = false, &block)
      count = 1
      loop do
        begin
          Hpr.log.debug "try ... #{count}" if verbose
          break if count > max_connect
          return yield
          break
        rescue e : Exception
          Hpr.log.debug " * #{e.class}: #{e.message}"
          count += 1
          sleep 1
        end
      end
    end
  end
end
