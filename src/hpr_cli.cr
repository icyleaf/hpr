require "./hpr"

spawn do
  Hpr::API.run
end

worker = Faktory::Worker.new
worker.run
