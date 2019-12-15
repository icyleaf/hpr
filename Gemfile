# frozen_string_literal: true

source 'https://rubygems.org'
# source 'https://gems.ruby-china.com'

git_source(:github) { |repo_name| "https://github.com/#{repo_name}" }

# Web Services
gem 'puma', '~> 4.3.1'
gem 'sidekiq', '~> 5.2.7'
gem 'sinatra', '~> 2.0.7'
gem 'sinatra-contrib', '~> 2.0.7'

# Database
gem 'activerecord', '~> 5.2.3'
gem 'sqlite3', '~> 1.4.1'

# Tools
gem 'chronic_duration', '~> 0.10.6'
gem 'commander', '~> 4.4.7'
gem 'git', '~> 1.5.0'
gem 'gitlab', '~> 4.12.0'
gem 'rake'
gem 'sentry-raven'
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
