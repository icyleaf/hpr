class Hpr::Server
  module API
    get "/" do |env|
      render_json env, {
        message: "welcome to hpr api layer",
      }
    end

    get "/info" do |env|
      render_json env, {
        hpr: {
          version:      Hpr::VERSION.to_s,
          repositroies: client.total_repositories,
        },
        jobs: jobs,
      }
    end

    get "/repositories/search" do |env|
      name = env.params.query["name"]
      repos = client.search_repositories(name)
      render_json env, {
        entry: repos,
      }
    end

    get "/repositories" do |env|
      total = client.total_repositories
      page = env.params.query.fetch("page", "1").to_i
      per_page = env.params.query.fetch("per_page", "1").to_i

      render_json env, {
        total: total,
        entry: client.list_repositories(page, per_page),
      }
    end

    get "/repositories/:name" do |env|
      name = env.params.url["name"]
      repo = client.repository(name)
      render_json env, repo
    end

    put "/repositories/:name" do |env|
      name = env.params.url["name"]
      job_id = client.update_repository(name)
      render_json env, {job_id: job_id}
    end

    post "/repositories" do |env|
      url = env.params.body["url"]
      name = env.params.body["name"]?
      create = env.params.body["create"]? || "true"
      clone = env.params.body["clone"]? || "true"

      job_id = client.create_repository(
        url, name,
        create == "true",
        clone == "true"
      )

      render_json env, {job_id: job_id}, 201
    end

    delete "/repositories/:name" do |env|
      name = env.params.url["name"]
      job_id = client.delete_repository(name)

      render_json env, {job_id: job_id}
    end

    error 404 do
      {message: "404 Not found"}.to_json
    end

    #################################

    @@client : Hpr::Client?

    # :nodoc:
    def self.client(config : Hpr::Config)
      @@client = Hpr::Client.new(config)
    end

    private def self.client
      @@client.not_nil!
    end

    private def self.jobs
      stats = Sidekiq::Stats.new
      {
        total_processed: stats.processed,
        total_failures:  stats.failed,
        total_queues:    stats.queues,
        total_enqueued:  stats.enqueued,
        total_scheduled: stats.scheduled_size,
        scheduleds:      scheduled_jobs,
      }
    end

    private def self.scheduled_jobs
      scheduled_set = Sidekiq::ScheduledSet.new
      scheduled_set.each_with_object([] of Hash(String, String|Time)) do |retri, obj|
        obj << {
          "name"         => retri.args[0].to_s,
          "scheduled_at" => retri.at.as(Time).in(Time::Location.load("Asia/Shanghai")).to_s,
        }
      end
    end

    private def self.render_json(env, body, status_code = 200)
      env.response.status_code = status_code
      env.response.headers["Content-Type"] = "application/json"

      body = body.to_json unless body.is_a?(String)
      body
    end
  end
end
