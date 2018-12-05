module Hpr::Model
  class Repository < Granite::Base
    adapter hpr
    table_name repository

    field! name : String
    field! url : String
    field! mirror_url : String
    field! status : String
    field! scheduled_at : Time
    timestamps

    before_create :set_default_status

    def set_default_status
      @status = "idle"
    end
  end
end
