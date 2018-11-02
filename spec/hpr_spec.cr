require "./spec_helper"

describe Hpr do
  describe "#config" do
    it "should returns same instance" do
      config = Hpr.config
      config.should eq(Hpr.config)
      config.object_id.should eq(Hpr.config.object_id)
    end

    it "should returns new config with path" do
      config = Hpr.config
      new_config = Hpr.config("examples/sass/config/hpr.json", 0)
      config.object_id.should eq(new_config.object_id)
    end
  end
end
