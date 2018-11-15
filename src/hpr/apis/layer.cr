require "sidekiq/api"

module Hpr::API
  class Entrance < Salt::App
    def call(env)
      Raven.breadcrumbs.record do |crumb|
        crumb.category = "api"
        crumb.timestamp = Time.now
        crumb.message = "Call #{self.class} API"
      end

      {200, {"Content-Type" => "application/json"}, [{message: "welcome to hpr api layer"}.to_json]}
    end
  end

  class Info < Salt::App
    def call(env)
      Raven.breadcrumbs.record do |crumb|
        crumb.category = "api"
        crumb.timestamp = Time.now
        crumb.message = "Call #{self.class} API"
      end

      client = Client.new
      stats = Sidekiq::Stats.new
      scheduled_set = Sidekiq::ScheduledSet.new
      scheduleds = scheduled_set.each_with_object([] of Hash(String, String)) do |retri, obj|
        obj << {
          "name"         => retri.args[0].to_s,
          "scheduled_at" => retri.at.to_s,
        }
      end

      names = client.list_repositories
      body = {
        hpr: {
          version:      Hpr::VERSION.to_s,
          repositroies: {
            total: names.size,
            entry: names,
          },
        },
        jobs: {
          total_processed: stats.processed,
          total_failures:  stats.failed,
          total_queues:    stats.queues,
          total_enqueued:  stats.enqueued,
          total_scheduled: stats.scheduled_size,
          scheduleds:      scheduleds,
        },
      }.to_json

      {200, {"Content-Type" => "application/json"}, [body]}
    rescue e : Exception
      Hpr.capture_exception(e, "api", params: env.params.to_h.to_s)
      body = {message: e.message}.to_json
      {400, {"Content-Type" => "application/json"}, [body]}
    end
  end

  class NotFound < Salt::App
    def call(env)
      Raven.breadcrumbs.record do |crumb|
        crumb.category = "api"
        crumb.timestamp = Time.now
        crumb.message = "Call #{self.class} API"
      end

      {404, {"Content-Type" => "application/json"}, [{messaeg: "Not found api"}.to_json]}
    end
  end
end
