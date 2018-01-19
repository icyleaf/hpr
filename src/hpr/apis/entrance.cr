module Hpr::API::Entrance
  get "/" do |env|
    env.response.content_type = "application/json"
    {
      message: "welcome to hpr api layer"
    }.to_json
  end
end
