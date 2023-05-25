# ~/lib/ruby/convert_hash_to_data.rb
#
# for use with TTY::Table

def convert_hash_to_data(headers, array_of_hashes)
  data = []
  array_of_hashes.each do |entry|
    row = []
    headers.each do |key|
      row << entry[key]
    end
    data << row
  end

  data
end

__END__

Usage:

require 'tty-table'

headers = [:key1, :key2, :key3]

array_of_hashes = [
  {
    key1: 'one',
    key2: 'two'
  },
  {
    key1: 'one',
    key2: 'two',
    key3: 'three'
  },
  {
    key2: 'two',
    key3: 'three'
  },
  {
    key3: 'three'
  }
]

data = convert_hash_to_data(headers, array_of_hashes)

table = TTY::Table.new(headers, data)
puts table

produces this output ...

key1 key2 key3
one  two
one  two  three
     two  three
          three
