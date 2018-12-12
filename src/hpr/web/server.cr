require "kemal"
require "kemal-basic-auth"
require "raven/integrations/kemal"
require "../core/*"
require "./api"

module Hpr
  class Server
    class HprExceptionHandler
      include HTTP::Handler

      def call(context : HTTP::Server::Context)
        call_next(context)
      rescue ex : Hpr::NotFoundRepositoryError | Hpr::NotFoundGitlabProjectError | Granite::Querying::NotFound
        render context, ex, 404
      rescue ex : Hpr::Error | Gitlab::Error::APIError | KeyError
        render context, ex, 400
      end

      private def render(context, exception, status_code = 400, backtrace = false)
        body = Hash(String, String | Array(String) | Nil).new.tap do |obj|
          obj["message"] = exception.message
          obj["backtrace"] = exception.backtrace if backtrace
        end.to_json

        context.response.status_code = status_code
        context.response.headers["Content-Type"] = "application/json"
        context.response.headers["Content-Length"] = body.size.to_s
        context.response << body
      end
    end

    extend API

    def self.run(config : Hpr::Config, port = 8848)
      new(config).run(port)
    end

    def initialize(@config : Hpr::Config)
      API.client(@config)
    end

    def run(port)
      set_basic_auth if basic_auth?

      Kemal.config.env = "production"
      Kemal.config.powered_by_header = false
      Kemal.config.add_handler Raven::Kemal::ExceptionHandler.new
      Kemal.config.add_handler HprExceptionHandler.new
      Kemal.run(port)
    end

    private def set_basic_auth
      user = @config.basic_auth.user
      password = @config.basic_auth.password
      basic_auth user, password
    end

    private def basic_auth?
      @config.basic_auth.enable
    end
  end
end
