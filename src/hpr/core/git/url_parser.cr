require "uri"

class Hpr::Git
  struct URLParser
    property namespace : String | Nil
    property name : String

    def self.parse(url : String)
      new(url)
    end

    def initialize(url : String)
      paths = path(url).split("/")
      @name = strip_tail paths.last
      @namespace = if paths.size >= 2
                     strip_tail paths[-2]
                   end
    end

    def mirror_name
      if @namespace
        "#{@namespace}-#{@name}"
      else
        @name
      end
    end

    private def path(url : String) : String
      case url
      when .starts_with?("git@"), .starts_with?("ssh"), .starts_with?("git://")
        url.split("@").last.split(":").last
      when .starts_with?("http")
        uri = URI.parse url
        path = uri.path.not_nil!
        path.starts_with?("/") ? path[1..-1] : path
      else
        raise UnkownURIError.new "Not support repository url: #{url}, avaiable in ssh/http(s) protocols."
      end
    end

    private def strip_tail(text : String)
      text.gsub(".git", "")
        .gsub("~", "")
    end
  end
end
