require "rake/testtask"

namespace :nodb do

task :default => [:test]

Rake::TestTask.new do |test|
  test.libs << "test"
  test.test_files = Dir[ "test/unit/*_test.rb" ]
  test.verbose = true
end

end