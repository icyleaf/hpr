class Hpr::Git
  module Helper
    extend self

    def write_mirror_to_git_config(repo, mirror_url : String)
      repo.set_config("credential.helper", "store")
      repo.add_remote("hpr", mirror_url)
      repo.add_config("remote.hpr.push", "+refs/heads/*:refs/heads/*")
      repo.add_config("remote.hpr.push", "+refs/tags/*:refs/tags/*")
      repo.set_config("remote.hpr.mirror", true)
    end
  end
end
