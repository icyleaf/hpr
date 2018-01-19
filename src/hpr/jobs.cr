require "faktory_worker"

module Hpr
  Faktory::Job.configure_defaults({
    :retry       => 10,
    :backtrace   => 6
  })
end

require "./jobs/*"
