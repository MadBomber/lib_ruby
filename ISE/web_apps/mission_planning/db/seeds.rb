## This is used in Rails 2.3.4 and later.

require 'active_record/fixtures'

fixtures_directory = "#{Rails.root}/test/fixtures"
puts "Fixtures Directory: #{fixtures_directory}"

Dir.foreach(fixtures_directory) do |entry|
  if File.fnmatch?('*.yml', entry)
    fixture = entry.split('.yml').first
    puts "Create fixture: #{fixture}"
    Fixtures.create_fixtures(fixtures_directory, fixture)
  end
end