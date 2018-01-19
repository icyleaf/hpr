require "./hpr"

spawn do
  worker = Faktory::Worker.new
  worker.run
end

Hpr::API.run
