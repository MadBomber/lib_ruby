# lib/ruby/find_files.rb

# ASSUMPTION: running on a *nix system that has a "find" command.

begin
  __find_files__ = `which find`
  raise 'GotWhichNoFind' if __find_files__.empty?
rescue Exception => e

  STDERR.puts <<~MESSAGE

    ERROR: #{e}
          This computer OS is not POSIX compliant
          It needs both a 'which' and 'find' command
          in order to use lib/ruby/find_files.rb

  MESSAGE
end

require 'pathname'

def find_files(file_name, starting_dir=Pathname.pwd, recursive: true)
  if Pathname == starting_dir.class
    starting_dir = starting_dir.realpath
  else
    starting_dir = Pathname.new(starting_dir).realpath
  end

  parameters = recursive ? '-name' : '-maxdepth 1 -name'

  find_command = "find #{String(starting_dir)} #{parameters} '#{String(file_name)}'"

  files = `#{find_command}`.split("\n").map {|file| Pathname.new(file)}

  return files
end

__END__
require 'awesome_print'

ap find_files '*.rb'
ap find_files '.bashrc*', ENV['HOME'], recursive: false

