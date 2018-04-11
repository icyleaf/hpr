module Hpr::API::Entrance
  get "/" do |env|
    env.response.content_type = "application/json"
    {
      message: "welcome to hpr api layer",
    }.to_json
  end

  get "/info" do |env|
    env.response.content_type = "application/json"

    names = CLIENT.list_repositories

    {
      hpr: {
        version:      Hpr::VERSION,
        repositroies: {
          total: names.size,
          entry: names,
        },
      },
      jobs: {
        todo: "dependence",
      },
    }.to_json
  end
end
