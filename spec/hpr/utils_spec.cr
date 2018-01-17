require "../spec_helper.cr"

describe Hpr::Utils do
  describe ".run_cmd" do
    it "should accept single command" do
      r = Hpr::Utils.run_cmd "echo hello", echo: false
      r.should be_a Array(String)
      r.size.should eq 1
      r[0].should eq "hello"
    end

    it "should accept multi command" do
      r = Hpr::Utils.run_cmd "echo hello", "echo world", echo: false
      r.should be_a Array(String)
      r.size.should eq 2
      r[0].should eq "hello"
      r[1].should eq "world"
    end
  end
end
