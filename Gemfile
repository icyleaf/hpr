# frozen_string_literal: true

source 'https://rubygems.org'

git_source(:github) { |repo_name| "https://github.com/#{repo_name}" }

# Web Services
gem 'puma', '~> 6.6.1'
gem 'sinatra', '~> 4.2.1'
gem 'sinatra-contrib', '~> 4.2.1'

# Background Job Service
gem 'sidekiq', '~> 8.0.8'
gem 'sidekiq-failures', '~> 1.0.4'

# Database
gem 'activerecord', '~> 8.0.3'
gem 'sqlite3', '~> 2.7.4'

# Tools
gem 'chronic_duration', '~> 0.10.6'
gem 'commander', '~> 5.0.0'
gem 'git', '~> 3.0.2'
gem 'gitlab', '~> 4.19.0'
gem 'rake', '>= 3.1.17'
gem 'sentry-ruby'
gem 'sentry-sidekiq'
gem 'settingslogic', '~> 2.0.9'

group :development, :test do
  # Test
  gem 'rack-test'
  gem 'rspec'
  gem 'rubocop'

  # Debug
  gem 'awesome_print'

  gem 'guard'
  gem 'guard-puma'
  gem 'guard-sidekiq'
end
