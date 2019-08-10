# frozen_string_literal: true

guard 'sidekiq', concurrency: 10, require: './lib/hpr.rb', verbose: true do
  watch(%r{^lib/hpr/workers/(.+)\.rb$})
end

ENV['HPR_SIDEKIQ_UI'] = 'true'
guard 'puma', config: './config/puma.rb' do
  watch('Gemfile.lock')
  watch(%r{^config|lib/hpr/(.+)\.rb$})
end
