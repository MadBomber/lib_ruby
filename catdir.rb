# ~/lib/ruby/catdir.rb
#
# This Ruby method finds and prints out the contents of all
# readable text files in a given directory. It makes use of
# the `Find` library to iterate through the directory
# structure.
#
# The `catdir` method can be particularly useful in contexts
# where you need to gather text data to provide additional
# context for LLM (Large Language Model) prompts.
#
# Usage:
# - Call `catdir` with a specific directory path to display
#   the contents of all the text files.
# - The default behavior is to operate in the current
#   working directory `Pathname.pwd` if no argument is
#   given.
#
# This method aids in understanding the content and
# structure of files within a directory and can be useful
# for curating relevant data when preparing inputs for LLM
# systems.
#
# Suggestion:
# To use `catdir` easily from the command line, you could
# create a shell alias by adding the following line to your
# shell configuration file (e.g., .bashrc or .zshrc):
# alias catdir='ruby -rcatdir -e "catdir"'
#
require "find"
require "pathname"

def catdir(dir=Pathname.pwd)
  Find.find(dir.to_s) do |path|
    if File.file?(path) && File.readable?(path)
      result = `file --mime-type -b "#{path}"`.strip
      if result.start_with?("text/")
        print "\n\n=== #{path} ===\n\n"
        puts File.read(path)
      end
    end
  end
end
