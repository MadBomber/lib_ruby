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

# These AppleScripts are not working correctly

def osascript(script)
  `osascript -e '#{script}'`
end

# Pressing controll key twic turns on Siri Dictation

def siri_dictation_on(delay: 0.1)
  osascript(<<~SCRIPT)
    tell application "System Events"
      key down control
      delay #{delay / 2}
      key up control
      delay #{delay}
      key down 
      delay #{delay / 2}
      key up control
    end tell  
  SCRIPT
end

__END__

def turn_on_siri_dictation
  osascript(<<~SCRIPT)
    tell application "System Events"
      tell process "System Preferences"
        set frontmost to true
        delay 1
        click menu item "Keyboard" of menu "View" of menu bar 1
        delay 1
        click tab group 1 of window "Keyboard"
        delay 1
        click button "Dictation" of tab group 1 of window "Keyboard"
        delay 1
        click radio button "On" of tab group 1 of window "Keyboard"
      end tell
    end tell
  SCRIPT
end


def turn_off_siri_dictation
  osascript(<<~SCRIPT)
    tell application "System Events"
      tell process "System Preferences"
        set frontmost to true
        delay 1
        click menu item "Keyboard" of menu "View" of menu bar 1
        delay 1
        click tab group 1 of window "Keyboard"
        delay 1
        click button "Dictation" of tab group 1 of window "Keyboard"
        delay 1
        click radio button "Off" of tab group 1 of window "Keyboard"
      end tell
    end tell
  SCRIPT
end

#  __END__

# Example usage
if dictating?
  puts "Siri Dictation is currently running."
else
  puts "Siri Dictation is not running."
end



# Example usage:
turn_on_siri_dictation
puts "Dictation is #{dictating?}"

print "Ready to copy what you say (CR when done) > "
input = gets
puts
puts "you said: #{input}"
puts

turn_off_siri_dictation # Uncomment to turn off
puts "Dictation is #{dictating?}"

print "Now you have to type (CR to submit) > "
input = gets

puts
puts "You typed: #{input}"
puts
