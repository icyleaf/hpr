require "uri"

module Hpr
  struct Repository
    property user : String
    property name : String
    property url : String

    def initialize(uri : String)
      @user, @name, @url = parse(uri)
    end

    private def parse(uri : String)
      user = name = url = ""
      if uri.starts_with?("git@")
        # git@github.com:icyleaf/hpr.git
        # git@gitlab.org:icyleaf/hpr.git

        git_user, host_with_path = uri.split("@")
        host, path = host_with_path.split(":")

        name = path.split("/")[-2..-1].join("-").gsub(".git", "")
        user = path.split("/")[0]
        url = "https://#{host}/#{path}"
      elsif uri.starts_with?("http")
        # https://github.com/icyleaf/hpr.git
        # http://gitlab.com/icyleaf/hpr.git

        url = URI.parse uri
        if path = url.path
          path = path[1..-1]
          name = path.split("/")[-2..-1].join("-").gsub(".git", "")
          user = name.split("-")[0]
        end
      else
        raise UnkownURIError.new "Not support current url: #{uri}"
      end

      [user, name, url.to_s]
    end
  end
end
