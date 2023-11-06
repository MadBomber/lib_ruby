# lib/ruby/bogosort.rb
#
# See: https://en.wikipedia.org/wiki/Bogosort
#

class Array
  def sorted?
    each_cons(2).all? { |a, b| a <= b }
  end

  def bogosort
    shuffle! until sorted?
    self
  end
end

__END__

puts Time.now

numbers = []
10.times {|x| numbers << rand(100) }
puts numbers.bogosort

puts Time.now
