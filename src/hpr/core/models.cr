require "./models/*"

module Hpr::Model
  def self.create_tables
    Repository.migrator.create
  end
end
