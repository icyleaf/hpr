# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path('./lib', __dir__)
# 初始化一些文件和目录，否则无法 docker 构建，构建的内容不会引入 docker
FileUtils.cp('config/hpr.example.yml', 'config/hpr.yml') unless File.file?('config/hpr.yml')
FileUtils.mkdir('logs') unless Dir.exist?('logs')

require 'fileutils'
require 'hpr'

namespace :db do
  desc 'Load table to db file'
  task :setup do
    Hpr.connect_database

    ActiveRecord::Schema.define do
      create_table :repositories, if_not_exists: true do |t|
        t.string    :name, null: false
        t.string    :url, null: false
        t.string    :mirror_url
        t.integer   :gitlab_project_id
        t.integer   :status, default: 0
        t.datetime  :scheduled_at
        t.timestamps
      end
    end
  end

  desc 'Drop db file'
  task :drop do
    File.delete Hpr.db_file
  end

  desc 'Drop db file and load it agin'
  task :reset do
    Rake::Task['db:reset'].invoke
    Rake::Task['db:setup'].invoke
  end
end

# development tasks
unless Hpr.producton?
  require 'rubocop/rake_task'
  require 'awesome_print'

  namespace :test do
    task :release_version do
      puts Hpr.hostname
      puts Hpr.running_env

      Raven.capture do
        1 / 0
      end
    end

    task :create do
      Hpr::Repository.create name: 'icyleaf-halite', url: 'git@github.com:icyleaf/halite.git'
    end
  end

  RuboCop::RakeTask.new

  IMAGE_NAME = 'icyleafcn/hpr'
  IMAGE_WITH_VERSION = "#{IMAGE_NAME}:#{Hpr::VERSION}"

  namespace :docker do
    desc 'Create docker image'
    task :build do
      system %(docker build -t #{IMAGE_WITH_VERSION} .)
    end

    desc 'Push hpr to docker hub'
    task :publish do
      system %(docker tag #{IMAGE_WITH_VERSION} #{IMAGE_NAME}:latest)
      system %(docker push #{IMAGE_WITH_VERSION})
      system %(docker push #{IMAGE_NAME}:latest)
    end

    desc 'Run a new hpr container'
    task :run do
      system %(docker run --rm -v `pwd`/config/hpr.example.yml:/app/config/hpr.yml -p 18848:8848 -p 16379:6379 #{IMAGE_WITH_VERSION})
    end

    desc 'Run a new hpr console'
    task :console do
      system %(docker run --rm -it #{IMAGE_WITH_VERSION} bash)
    end
  end
end
