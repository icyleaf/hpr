require "../spec_helper.cr"

describe Hpr::Repository do
  describe "#new" do
    it "should parse github repo url with http" do
      url = "https://github.com/icyleaf/hpr.git"
      repo = Hpr::Repository.new url
      repo.url.should eq url
      repo.name.should eq "icyleaf-hpr"
      repo.user.should eq "icyleaf"
    end

    it "should parse gitlab repo url with http" do
      url = "https://gitlab.com/icyleaf/hpr.git"
      repo = Hpr::Repository.new url
      repo.url.should eq url
      repo.name.should eq "icyleaf-hpr"
      repo.user.should eq "icyleaf"
    end

    it "should parse coding repo url with http" do
      url = "https://git.coding.net/icyleaf/hpr.git"
      repo = Hpr::Repository.new url
      repo.url.should eq url
      repo.name.should eq "icyleaf-hpr"
      repo.user.should eq "icyleaf"
    end

    it "should parse git user with host" do
      url = "git@github.com:icyleaf/hpr.git"
      repo = Hpr::Repository.new url
      repo.url.should eq "https://github.com/icyleaf/hpr.git"
      repo.name.should eq "icyleaf-hpr"
      repo.user.should eq "icyleaf"
    end

    it "should parse http with path" do
      url = "https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git"
      repo = Hpr::Repository.new url
      repo.url.should eq url
      repo.name.should eq "torvalds-linux"
      repo.user.should eq "torvalds"
    end

    it "throws an exception with unsupport url" do
      # https://github.com/berkshelf/berkshelf/issues/257
      urls = [
        "ssh://git@example.com:2233/foo/bar.git",
        "ssh://git@example.com/~foo/bar.git",
        "git://example.com/foo/bar.git",
        "git://example.com:2323/~foo/bar.git",
        "ftp://example.com:21/a/b/c/foo/bar",
      ]

      urls.each do |url|
        expect_raises Hpr::UnkownURIError do
          Hpr::Repository.new url
        end
      end
    end
  end
end
