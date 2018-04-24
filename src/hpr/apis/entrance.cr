require "sidekiq/api"

module Hpr::API::Entrance
  get "/" do |env|
    env.response.content_type = "application/json"
    {
      message: "welcome to hpr api layer",
    }.to_json
  end

  get "/info" do |env|
    env.response.content_type = "application/json"

    stats = Sidekiq::Stats.new
    names = CLIENT.list_repositories

    {
      hpr: {
        version:      Hpr::VERSION,
        repositroies: {
          total: names.size,
          entry: names,
        }
      },
      jobs: {
        total_scheduled: stats.scheduled_size,
        total_enqueued: stats.enqueued,
        total_failures: stats.failed,
        total_processed: stats.processed,
        total_queues: stats.queues
      },
    }.to_json
  end
end