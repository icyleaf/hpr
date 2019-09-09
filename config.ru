# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path('./lib', __dir__)

require 'bundler/setup'
require 'sidekiq/web'
require 'hpr'

puts <<-BANNER
   _
  | |__  _ __  _ __
  | '_ \\| '_ \\| '__|
  | | | | |_) | |
  |_| |_| .__/|_|
      |_|         v#{Hpr::VERSION}
BANNER

if ENV['HPR_SIDEKIQ_UI']
  run Rack::URLMap.new('/' => Hpr::Web, '/sidekiq' => Sidekiq::Web)
else
  run Hpr::Web
end
