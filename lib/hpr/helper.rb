# frozen_string_literal: true

module Hpr
  # Helper
  module Helper
    def self.git_url_parse(url)
      URLParser.parse(url)
    end

    # Git URL Parser
    class URLParser
      attr_accessor :namespace, :name

      def self.parse(url)
        instance = new(url)
        instance.parse
        instance
      end

      def initialize(url)
        @url = url
      end

      def parse
        paths = parse_paths
        @name = strip_tail(paths.last)
        @namespace = strip_tail(paths[-2]) if paths.size >= 2
      end

      def mirror_name
        if @namespace
          "#{@namespace}-#{@name}"
        else
          @name
        end
      end

      private

      def parse_paths
        if ssh_protocol?
          ssh_paths
        elsif http_protocol?
          http_paths
        else
          raise "Not support repository url: #{url}, avaiable in ssh/http(s) protocols."
        end
      end

      def ssh_paths
        @url.split('@').last.split(':').last.split('/')
      end

      def http_paths
        uri = URI.parse(@url)
        path = uri.path
        (path.start_with?('/') ? path[1..] : path).split('/')
      end

      def ssh_protocol?
        !['git@', 'ssh', 'git://'].select { |v| @url.start_with?(v) }.empty?
      end

      def http_protocol?
        @url.start_with?('http')
      end

      def strip_tail(text)
        text.gsub('.git', '').gsub('~', '')
      end
    end
  end
end
