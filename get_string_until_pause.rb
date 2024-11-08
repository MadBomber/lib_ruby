# ~/lib/ruby/get_string_until_pause.rb

require 'io/console'
require 'timeout_block'   # See ~/lib/ruby

def get_string_until_pause(pause: 5)
  a_string = ""

  loop do
    char = timeout_block(pause) { IO.console.getch }
    break if char.nil?
    print char
    a_string << char
  end

  a_string
end


__END__

print "> "
result = get_string_until_pause(pause: 5)

puts "\nYou entered: #{result}"
