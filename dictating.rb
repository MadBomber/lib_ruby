#! #!/usr/bin/env ruby
# ~/lib/ruby/dictating.rb
#
# Is Siri Dication turned on?
#
def dictating?
  processes = `pgrep -f "Dictation"`

  !processes.strip.empty?
end

__END__

# Example usage
if dictating?
  puts "Siri Dictation is currently running."
else
  puts "Siri Dictation is not running."
end
