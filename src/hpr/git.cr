require "../hpr"
require "./git/*"
require "terminal"


module Hpr::Git
  @@binary : String = `which git`.strip

  def self.ensure!
    raise NotFoundGitError.new("Not found git in PATH, Set it into PATH or install it.") if @@binary.empty?
  end

  def self.command(path, *args)
    ensure!

    Dir.cd(path) do
      cmd = args.to_a.compact.join(" ")
      Terminal.sh(@@binary, cmd, print_command: Hpr.debugging, print_command_output: Hpr.debugging).output
    end
  end

  class Repo
    def self.repository(name : String)
      new(repository_path(name))
    end

    def self.repository_path?(name : String)
      path = repository_path(name)
      Dir.exists?(path) ? path : nil
    end

    def self.repository_path(name)
      File.join(Hpr.config.repository_path, name)
    end

    getter path

    def initialize(@path : String)
    end

    def clone(url : String, name : String, mirror = false)
      output = exec("clone", mirror ? "--mirror" : "", url, name)
      @path = File.join(@path, name)
      output
    end

    def clone(url : String, mirror = false)
      exec("clone", mirror ? "--mirror" : "", url, File.basename(@path))
    end

    def remotes
      Hash(String, Remote).new.tap do |obj|
        exec("remote").split("\n").each do |name|
          pull_url = exec("remote get-url", name)
          push_url = exec("remote get-url --push", name)
          mirror = config("remote.#{name}.mirror", "false") == "true"
          obj[name] = Remote.new(self, name, pull_url, push_url, mirror)
        end
      end
    end

    def remote(name)
      remotes[name]
    end

    def add_remote(name, pull_url, push_url : String? = nil, mirror = false)
      exec("remote add", mirror ? "--mirror=push" : nil, name, pull_url)
      exec("remote set-url --push", name, push_url) if push_url

      push_url = pull_url unless push_url
      Remote.new(self, name, pull_url, push_url, mirror)
    end

    def update_remote(name, url, only_push = false)
      exec("remote set-url", only_push ? "--push" : nil, name, url)
    end

    def fetch_remote(name)
      exec("fetch", name)
    end

    def push_remote(name, mirror = false)
      exec("push", name, mirror ? "--mirror" : nil)
    end

    def delete_remote(name)
      exec("remote rm", name)
    end

    def tags
      exec("tag").split("\n")
    end

    def add_tag(name, message : String? = nil)
      exec("tag", message ? "-m #{message}" : nil, name)
    end

    def delete_tag(name)
      exec("tag -d", name)
    end

    def branches
      exec("branch | awk -F ' +' '! /\(no branch\)/ {print $2}'").split("\n")
    end

    def latest_hash
      exec("rev-parse HEAD")
    end

    def latest_tag
      exec("describe --tags --abbrev=0 2>/dev/null")
    end

    def config(key : String, default_value : (String|Int32|Float64|Bool)? = nil)
      exec("config --get", default_value ? "--default #{quote_string(default_value)}" : nil, key)
    end

    def set_config(key : String, value)
      exec("config", key, quote_string(value))
    end

    def add_config(key : String, value, append = false)
      exec("config", append ? "--add" : nil, key, quote_string(value))
    end

    def cloning?
      !repo?
    end

    def repo?
      has_refs?(bare? ? nil : ".git")
    end

    def bare?
      exec("rev-parse --is-bare-repository") == "true"
    end

    def exists?
      Dir.exists?(@path)
    end

    def exec(*args)
      Git.command(@path, *args)
    end

    private def has_refs?(path : String? = nil)
      path = path ? File.join(@path, path) : @path
      File.file?(File.join(path, "packed-refs"))
    end

    private def quote_string(text)
      text.is_a?(String) ? "'#{text}'" : text
    end

    record Remote, repo : Git::Repo, name : String, pull_url : String, push_url : String, mirror : Bool do
      def fetch
        repo.fetch_remote(name)
      end

      def push(mirror = false)
        repo.push_remote(name, mirror)
      end

      def set_url(url, only_push = false)
        repo.update_remote(name, url, only_push)
      end
    end
  end
end
