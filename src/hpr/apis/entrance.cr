require "sidekiq/api"

module Hpr::API
  class Entrance < Salt::App
    def call(env)
      {
        200,
        {
          "Content-Type" => "application/json"
        },
        [
          { message: "welcome to hpr api layer" }.to_json
        ]
      }
    end
  end

  class Info < Salt::App
    def call(env)
      stats = Sidekiq::Stats.new
      scheduled_set = Sidekiq::ScheduledSet.new
      scheduleds = scheduled_set.each_with_object([] of Hash(String, String)) do |retri, obj|
      #   obj << {
      #     "name"         => retri.args[0].to_s,
      #     "scheduled_at" => retri.at.to_s,
      #   }
      end

      # names = CLIENT.list_repositories
      # body = {
      #   "hpr" => {
      #     "version" => Hpr::VERSION.to_s,
      #     # repositroies: {
      #     #   total: names.size,
      #     #   entry: names,
      #     # },
      #   },
      #   # jobs: {
      #   #   total_scheduled: stats.scheduled_size,
      #   #   total_enqueued:  stats.enqueued,
      #   #   total_failures:  stats.failed,
      #   #   total_processed: stats.processed,
      #   #   total_queues:    stats.queues,
      #   #   scheduleds:      scheduleds,
      #   # },
      # }.to_json

      { 200, { "Content-Type" => "application/json" }, [ "{}" ] }
    end
  end
end
