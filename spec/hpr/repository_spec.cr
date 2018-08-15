require "../spec_helper.cr"

describe Hpr::Repository do
  describe "#new" do
    context "with http protocol" do
      it "should parse only one path" do
        url = "http://icyleaf.git.com/hpr.git"
        repo = Hpr::Repository.new url
        repo.url.should eq url
        repo.namespace.should be_nil
        repo.name.should eq "hpr"
        repo.mirror_name.should eq "hpr"
      end

      it "should parse two paths" do
        url = "http://git.example.com/EWS-Team/hpr.git"
        repo = Hpr::Repository.new url
        repo.url.should eq url
        repo.namespace.should eq "EWS-Team"
        repo.name.should eq "hpr"
        repo.mirror_name.should eq "EWS-Team-hpr"
      end

      it "should parse long paths" do
        url = "http://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git"
        repo = Hpr::Repository.new url
        repo.url.should eq url
        repo.namespace.should eq "torvalds"
        repo.name.should eq "linux"
        repo.mirror_name.should eq "torvalds-linux"
      end

      it "should parse with custom port" do
        url = "http://icyleaf.git.com:82/icyleaf.git"
        repo = Hpr::Repository.new url
        repo.url.should eq url
        repo.namespace.should be_nil
        repo.name.should eq "icyleaf"
        repo.mirror_name.should eq "icyleaf"
      end
    end

    context "with https protocol" do
      it "should parse only one path" do
        url = "https://icyleaf.git.com/hpr.git"
        repo = Hpr::Repository.new url
        repo.url.should eq url
        repo.namespace.should be_nil
        repo.name.should eq "hpr"
        repo.mirror_name.should eq "hpr"
      end

      it "should parse two paths" do
        url = "https://github.com/icyleaf/hpr.git"
        repo = Hpr::Repository.new url
        repo.url.should eq url
        repo.namespace.should eq "icyleaf"
        repo.name.should eq "hpr"
        repo.mirror_name.should eq "icyleaf-hpr"
      end

      it "should parse long paths" do
        url = "https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git"
        repo = Hpr::Repository.new url
        repo.url.should eq url
        repo.namespace.should eq "torvalds"
        repo.name.should eq "linux"
        repo.mirror_name.should eq "torvalds-linux"
      end

      it "should parse with custom port" do
        url = "https://icyleaf.git.com:82/hpr.git"
        repo = Hpr::Repository.new url
        repo.url.should eq url
        repo.namespace.should be_nil
        repo.name.should eq "hpr"
        repo.mirror_name.should eq "hpr"
      end
    end

    context "with ssh protocol starts with ssh" do
      it "should parse only one path" do
        url = "ssh://icyleaf@icyleaf.git.com:hpr.git"
        repo = Hpr::Repository.new url
        repo.url.should eq url
        repo.namespace.should be_nil
        repo.name.should eq "hpr"
        repo.mirror_name.should eq "hpr"
      end

      it "should parse two paths" do
        url = "ssh://git@github.com:icyleaf/hpr.git"
        repo = Hpr::Repository.new url
        repo.url.should eq url
        repo.mirror_name.should eq "icyleaf-hpr"
        repo.namespace.should eq "icyleaf"
        repo.name.should eq "hpr"
      end

      it "should parse long paths" do
        url = "ssh://git@github.com:~icyleaf/hpr.git"
        repo = Hpr::Repository.new url
        repo.url.should eq url
        repo.namespace.should eq "icyleaf"
        repo.name.should eq "hpr"
        repo.mirror_name.should eq "icyleaf-hpr"
      end

      it "should parse with custom port" do
        url = "ssh://git@github.com:2222/icy-leaf/hpr.git"
        repo = Hpr::Repository.new url
        repo.url.should eq url
        repo.namespace.should eq "icy-leaf"
        repo.name.should eq "hpr"
        repo.mirror_name.should eq "icy-leaf-hpr"
      end
    end

    context "with ssh protocol starts without ssh" do
      it "should parse only one path" do
        url = "git@icyleaf.git.com:hpr.git"
        repo = Hpr::Repository.new url
        repo.url.should eq url
        repo.namespace.should be_nil
        repo.name.should eq "hpr"
        repo.mirror_name.should eq "hpr"
      end

      it "should parse two paths" do
        url = "git@github.com:icyleaf/hpr.git"
        repo = Hpr::Repository.new url
        repo.url.should eq url
        repo.namespace.should eq "icyleaf"
        repo.name.should eq "hpr"
        repo.mirror_name.should eq "icyleaf-hpr"
      end

      it "should parse long paths" do
        url = "git@long.git.com:long/long/long/path/to/~icyleaf/hpr.git"
        repo = Hpr::Repository.new url
        repo.url.should eq url
        repo.mirror_name.should eq "icyleaf-hpr"
        repo.namespace.should eq "icyleaf"
        repo.name.should eq "hpr"
      end

      it "should parse with custom port" do
        url = "git@github.com:2222/icy-leaf/hpr.git"
        repo = Hpr::Repository.new url
        repo.url.should eq url
        repo.namespace.should eq "icy-leaf"
        repo.name.should eq "hpr"
        repo.mirror_name.should eq "icy-leaf-hpr"
      end
    end

    context "with git protocol" do
      it "should parse only one path" do
        url = "git://icyleaf.git.com:hpr.git"
        repo = Hpr::Repository.new url
        repo.url.should eq url
        repo.namespace.should be_nil
        repo.name.should eq "hpr"
        repo.mirror_name.should eq "hpr"
      end

      it "should parse two paths" do
        url = "git://github.com:icyleaf/hpr.git"
        repo = Hpr::Repository.new url
        repo.url.should eq url
        repo.namespace.should eq "icyleaf"
        repo.name.should eq "hpr"
        repo.mirror_name.should eq "icyleaf-hpr"
      end

      it "should parse long paths" do
        url = "git://github.com:~icyleaf/hpr.git"
        repo = Hpr::Repository.new url
        repo.url.should eq url
        repo.namespace.should eq "icyleaf"
        repo.name.should eq "hpr"
        repo.mirror_name.should eq "icyleaf-hpr"
      end

      it "should parse with custom port" do
        url = "git://github.com:2222/icy-leaf/hpr.git"
        repo = Hpr::Repository.new url
        repo.url.should eq url
        repo.namespace.should eq "icy-leaf"
        repo.name.should eq "hpr"
        repo.mirror_name.should eq "icy-leaf-hpr"
      end
    end

    context "with un-support protocol" do
      it "throws an exception with git and ftp protocols" do
        # https://github.com/berkshelf/berkshelf/issues/257
        urls = [
          "ftp://example.com:21/a/b/c/foo/bar",
          "/tmp/git/icyleaf/hpr",
        ]

        urls.each do |url|
          expect_raises Hpr::UnkownURIError do
            Hpr::Repository.new url
          end
        end
      end
    end
  end
end
