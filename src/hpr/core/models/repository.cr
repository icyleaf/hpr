module Hpr::Model
  class Repository < Granite::Base
    # Temporary, it wiil be setted outsite
    class_property adapter : Granite::Adapter::Base = Granite::Adapter::Sqlite.new({url: "", name: "hpr"})

    table_name repository

    field! name : String
    field! url : String
    field! mirror_url : String
    field! status : String
    field  scheduled_at : Time
    timestamps

    before_create :set_default_status

    def set_default_status
      @status = "idle"
    end
  end
end
