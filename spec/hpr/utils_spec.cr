require "../spec_helper.cr"

describe Hpr::Utils do
  describe ".run_cmd" do
    it "should accept single command" do
      output, error, status = Hpr::Utils.run_cmd "echo hello"

      output.should eq "hello"
      error.should eq ""
      status.should eq true
    end
  end
end
