# load_gems.rb
# Uses bundle/inline to insure that gem libraries are available
# Its intended for small apps.
# Note that the bundler/inline sets the load path so that only
# the specified gems are available.

begin
  require 'bundler/inline'
rescue
  system "gem install bundler"
  require 'bundler/inline'
end

# TODO: Might want to allow specific versions of the gems in addition to their names

def load_gems(an_array_of_strings)

  print "Installing gems as necessary ... " if $debug
  gemfile do
    source 'https://rubygems.org'
    Array(an_array_of_strings).each do |gem_name|
      print gem_name + ' ' if $debug
      gem gem_name
    end
  end

  puts 'done' if $debug

end # def load_gems(an_array_of_strings)

__END__

Typical Usage:

require 'load_gems'
load_gems %w[
  awesome_print cli_helper debug_me loofah mail progress_bar rethinkdb_helper
]


