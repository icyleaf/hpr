require "./hpr"

puts "Hpr worker is running ..."
worker = Faktory::Worker.new
worker.run
