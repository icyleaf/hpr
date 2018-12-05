require "salt"
require "raven"

module Hpr
  module API
    class ErrorHandler < Salt::App
      def call(env)
        Raven.breadcrumbs.record do |crumb|
          unless (200...400).includes?(status_code)
            crumb.level = :error
          end

          crumb.type = :http
          crumb.category = "api"
          crumb.timestamp = Time.now
          crumb.message = "Call #{self.class} API"
          crumb.data = {
            method:      env.method.upcase,
            url:         env.url,
            status_code: status_code,
          }
        end

        call_app(env)

        [status_code, headers, body]
      rescue ex : Exception
        Raven.capture(ex) do |event|
          event.logger ||= "hpr"

          event.interface :http, {
            headers:      headers_to_hash(env.headers),
            cookies:      cookies_to_string(env.cookies),
            method:       env.method,
            url:          env.url,
            query_string: env.query.to_s,
            data:         form_data(env),
          }
        end

        body = {
          message:   ex.message,
          backtrace: ex.backtrace,
        }.to_json

        {
          500,
          {
            "Content-Type"   => "text/json",
            "Content-Length" => body.bytesize.to_s,
          },
          [body],
        }
      end

      private def form_data(env)
        env.params.to_h
      end

      private def headers_to_hash(headers : HTTP::Headers)
        headers.each_with_object(AnyHash::JSON.new) do |(k, v), hash|
          hash[k] = v.join ", "
        end
      end

      private def cookies_to_string(cookies : Salt::Environment::Cookies::CookiesProxy)
        return if cookies.empty?

        cookies.to_h.map(&.last.to_cookie_header).join "; "
      end
    end
  end
end
