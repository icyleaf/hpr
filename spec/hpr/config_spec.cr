require "../spec_helper.cr"

CONFIG_FILE = "./config/hpr.json.example"

describe Hpr::Config do
  describe ".load" do
    it "should load from a file" do
      config = Hpr::Config.load CONFIG_FILE
      config.should be_a Hpr::Config
      config.repository_path.should eq File.expand_path("repositories")

      config.gitlab.should be_a Hpr::Config::GitlabStruct
      config.gitlab.ssh_port.should eq 22
      config.gitlab.endpoint.should be_a URI
      config.gitlab.endpoint.scheme.should eq "http"
      config.gitlab.endpoint.port.should eq nil
      config.gitlab.group_name.should eq "mirrors"

      config.repository_path = "/path/to/repositories"
      config.repository_path.should eq "/path/to/repositories"

      config.schedule.should eq 1.hour.to_i
      config.schedule.should eq 3600
      config.schedule = 5.minutes.to_i
      config.schedule.should eq 300
    end
  end
end
