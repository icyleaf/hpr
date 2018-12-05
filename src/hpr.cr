require "./hpr/core/*"


# require "./hpr/*"
# require "gitlab"
# require "raven"

module Hpr
#   extend self

  VERSION = "0.9.1"

#   @@config : Config?
#   @@gitlab : Gitlab::Client?
#   @@debugging = false

#   def config
#     @@config ||= Config.load
#     @@config.not_nil!
#   end

#   def config(file : String)
#     @@config = Config.load(file)
#     @@config.not_nil!
#   end

#   def gitlab
#     @@gitlab ||= Gitlab.client(config.gitlab.endpoint.to_s, config.gitlab.private_token)
#     @@gitlab.not_nil!
#   end

#   def debugging
#     @@debugging
#   end

#   def debugging(value : Bool)
#     @@debugging = value
#   end



#   def capture_exception(exception, category : String, print_output_error = false, file = __FILE__, **extra)
#     gitlab_version = "unkown"
#     begin
#       gitlab_version = gitlab.version
#     rescue
#       # do nothing
#     end

#     Raven.capture(exception) do |event|
#       event.logger ||= "hpr"
#       event.tags = {
#         deploy:   ENV.fetch("HPR_DEPLOY", "binary"),
#         category: category,
#       }
#       event.extra = {
#         git_version:     `git version`.strip,
#         redis_version:   `redis-server -v`.strip,
#         gitlab_version:  gitlab_version,
#         gitlab_endpoint: config.gitlab.endpoint.to_s,
#         file:            file,
#       }.merge(extra)
#     end

#     if print_output_error
#       Terminal.error "[#{exception.class}] #{exception.message}"
#       Terminal.error "  #{exception.backtrace.join("\n  ")}"
#     end
#   end
end
