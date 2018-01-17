unless ARGV.size > 0
  puts "  Missing executable file argument"
  puts "  Usage (in a Dockerfile)"
  puts "  RUN crystal run ./path/to/list-deps.cr -- ./bin/executable"
  exit 1
end

executable = File.expand_path(ARGV[0])

unless File.exists?(executable)
  puts "  Unable to find #{executable}"
  exit 1
end

puts "  Extracting libraries for #{executable} ..."

deps = [] of String
output = `ldd #{executable}`.scan(/(\/.*)\s\(/) do |m|
  library = m[1]
  deps << library

  real_lib = File.real_path(library)
  deps << real_lib if real_lib != library
end

puts "  Generating Dockerfile"
puts
puts "=" * 30
puts "FROM scratch"
deps.each do |dep|
  puts "COPY --from=0 #{dep} #{dep}"
end
puts "COPY --from=0 #{executable} /#{File.basename(executable)}"
puts "ENTRYPOINT [\"/#{File.basename(executable)}\"]"
puts "=" * 30
