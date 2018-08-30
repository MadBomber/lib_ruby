# ;ib/ruby/pancake_sort.rb

# Add the really slow pancake-style sort to the Array class
class Array

  # This is slow; never use it!
  def pancake_sort!
    (self.size-1).downto(1) do |end_idx|
      max,      = self[0..end_idx].max
      max_idx   = self[0..end_idx].index(max)
      next if max_idx == end_idx

      self[0..max_idx] = self[0..max_idx].reverse if max_idx > 0
      self[0..end_idx] = self[0..end_idx].reverse
    end # (self.size-1).downto(1) do |end_idx|
    self
  end # def pancake_sort!
end # class Array

__END__

stack = [1, 4, 5, 2, 3, 8, 6, 7, 9, 0]

puts "\nUnsorted:"
puts stack

puts "\nSorted:"
puts stack.pancake_sort!
puts
