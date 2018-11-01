require "../spec_helper.cr"

private CONFIG_FILE = "./config/hpr.json.example"

describe Hpr::Config do
  describe ".load" do
    it "should load from a file" do
      config = Hpr::Config.load CONFIG_FILE
      config.should be_a Hpr::Config
      config.repository_path.should eq File.expand_path(File.join("repositories", config.gitlab.group_name))

      config.gitlab.should be_a Hpr::Config::GitlabStruct
      config.gitlab.ssh_port.should eq 22
      config.gitlab.endpoint.should be_a URI
      config.gitlab.endpoint.scheme.should eq "http"
      config.gitlab.endpoint.port.should eq nil
      config.gitlab.group_name.should eq "mirrors"

      config.repository_path = "/path/to/repositories"
      config.repository_path.should eq "/path/to/repositories"

      config.schedule_in = "2.weeks"
      config.schedule_in.should eq 2.weeks
      config.schedule_in = 30
      config.schedule_in.should eq 30.minutes
    end
  end
end
