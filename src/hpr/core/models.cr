require "granite/adapter/sqlite"

Granite::Adapters << Granite::Adapter::Sqlite.new({name: "hpr", url: "sqlite3://#{Hpr.db_path}"})

module Hpr::Model
  def self.init
    Repository.migrator.create
  end
end

require "./models/*"
