class Hpr::Cli
  class Search < Command
    def run(**args)
      # name = args[:name]
      # Terminal.message "searching repositories ... #{name}"
      # repositories = client.search_repositories(name).each_with_object([] of Hash(String, String)) do |n, obj|
      #   obj << repository_info(n)
      # end

      # if repositories.empty?
      #   Terminal.important "Not found repositories"
      #   return
      # end

      # Terminal.message "found repositories (#{repositories.size}):"
      # repositories.each do |repo|
      #   dump_repository(repo)
      # end
    end
  end
end
