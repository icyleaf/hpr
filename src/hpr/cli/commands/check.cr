require "colorize"

class Hpr::Cli
  class Check < Command
    def run(**args)
      gitlab = Gitlab.client(@config.gitlab.endpoint, @config.gitlab.private_token)

      stats = Stats.new
      stats.report do
        testing "Checking service status of gitlab" do
          gitlab_available?(gitlab)
        end

        testing "Checking authorize of gitlab" do
          gitlab_authorized?(gitlab)
        end

        testing "Checking group of gitlab" do
          gitlab_has_group?(gitlab)
        end

        testing "Checking create project role of gitlab" do
          gitlab_user_can_create_project?
        end

        testing "Checking ssh key of gitlab" do
          gitlab_has_ssh_key?(gitlab)
        end
      end

      stats.passed?
    end

    private def gitlab_available?(gitlab)
      gitlab.available? ? {true, nil} : {false, "Gitlab connection failed, Check your gitlab settings"}
    rescue Gitlab::Error::InternalServerError
      {false, "Gitlab connection failed, check your gitlab settings"}
    rescue Gitlab::Error::Unauthorized
      {false, "Gitlab unauthorized, check your private token of gitlab"}
    end

    private def gitlab_authorized?(gitlab)
      gitlab_user(gitlab)
      {true, nil}
    rescue Gitlab::Error::InternalServerError
      {false, "Gitlab connection failed, Check your gitlab settings"}
    rescue Gitlab::Error::Unauthorized
      {false, "Gitlab unauthorized, check your private token of gitlab"}
    end

    private def gitlab_has_group?(gitlab)
      gitlab.group @config.gitlab.group_name
      {true, nil}
    rescue Gitlab::Error::NotFound
      gitlab_user_can_create_group?
    rescue Gitlab::Error::InternalServerError
      {false, "Gitlab connection failed, Check your gitlab settings"}
    rescue Gitlab::Error::Unauthorized
      {false, "Gitlab unauthorized, check your private token of gitlab"}
    end

    private def gitlab_has_ssh_key?(gitlab)
      ssh_keys = gitlab.ssh_keys.as_a
      if ssh_keys.empty?
        {false, "Please add ssh key for '#{gitlab_user["name"]}' user."}
      else
        has_ssh_key?(ssh_keys)
      end
    rescue Gitlab::Error::InternalServerError
      {false, "Gitlab connection failed, Check your gitlab settings"}
    rescue Gitlab::Error::Unauthorized
      {false, "Gitlab unauthorized, check your private token of gitlab"}
    end

    private def gitlab_user_can_create_group?
      if gitlab_user["can_create_project"].as_bool
        {true, nil}
      else
        {false, "Not found `#{@config.gitlab.group_name}` and you had no create group role, create it or enable role"}
      end
    rescue Gitlab::Error::InternalServerError
      {false, "Gitlab connection failed, Check your gitlab settings"}
    rescue Gitlab::Error::Unauthorized
      {false, "Gitlab unauthorized, check your private token of gitlab"}
    end

    private def gitlab_user_can_create_project?
      if gitlab_user["can_create_project"].as_bool
        {true, nil}
      else
        {false, "Please enable create project role."}
      end
    rescue Gitlab::Error::InternalServerError
      {false, "Gitlab connection failed, Check your gitlab settings"}
    rescue Gitlab::Error::Unauthorized
      {false, "Gitlab unauthorized, check your private token of gitlab"}
    end

    private def has_ssh_key?(ssh_keys)
      ssh_keys.each do |ssh_key|
        return {true, nil} if local_ssh_public_keys.values.includes?(ssh_key.as_h["key"])
      end

      {false, "Not found ssh key in gitlab, upload any of it in #{local_ssh_public_keys.keys}"}
    rescue Gitlab::Error::InternalServerError
      {false, "Gitlab connection failed, Check your gitlab settings"}
    rescue Gitlab::Error::Unauthorized
      {false, "Gitlab unauthorized, check your private token of gitlab"}
    end

    private def local_ssh_public_keys
      path = File.expand_path("~/.ssh/")

      ssh_keys = Hash(String, String).new
      Dir.glob(File.join(path, "*.pub")) do |path|
        filename = File.basename(path)
        ssh_keys[filename] = File.read(path).strip
      end
      ssh_keys
    end

    @user : Hash(String, JSON::Any)?

    private def gitlab_user(gitlab)
      @user ||= gitlab.user.as_h
      @user.not_nil!
    end

    private def gitlab_user
      @user.not_nil!
    end

    class Stats
      @total = 0
      @fail = 0

      def report
        with self yield

        puts
        if @fail.zero?
          puts "Everthing is smooth!".colorize(:green)
        else
          STDERR.puts "Found #{@fail} errors.".colorize(:red)
        end
      end

      def passed?
        @fail.zero?
      end

      def testing(title, &block)
        print "#{title} ... "
        status, message = yield
        if status
          puts "[OK]".colorize(:green)
        else
          puts "[FATAL] #{message}".colorize(:red)
        end

        count(status)
      end

      private def count(status)
        @total += 1
        @fail += 1 unless status
        status
      end
    end
  end
end
