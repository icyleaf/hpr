# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path('./lib', __dir__)

require 'bundler/setup'
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
  require 'securerandom'
  require 'sidekiq/web'

  session_key = File.join('config', '.sidekiq_session.key')
  File.open(session_key, 'w') { |f| f.write(SecureRandom.hex(32)) }

  use Rack::Session::Cookie, secret: File.read(session_key), same_site: true, max_age: 86400
  run Rack::URLMap.new('/' => Hpr::Web, '/sidekiq' => Sidekiq::Web)
else
  run Hpr::Web
end
