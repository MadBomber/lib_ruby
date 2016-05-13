###################################################
###
##  File: asciitree.rb
##  Desc: Saw a python version of asciitree when playing with Google's syntaxNet software
##        Thought the python code was too complex for what it did; so wrote this.
#

def asciitree(an_array, level=0)
  an_array.each do |a|
    if Array == a.class
      if Array == a.first.class
        prefix = ("|-- "*level) + "|-- v"
        (level+1).times { prefix.gsub!('|-- |', '|   |') }
        puts prefix
      end
      asciitree(a, level+1)
    else
      prefix = "|-- "*level
      level.times { prefix.gsub!('|-- |', '|   |') }
      puts prefix + a.to_s
    end
  end
end

=begin
array = [0, [1, 1, 1], 0, [1, [2, [[4,4,4],3,3], 2], 1], 0]

asciitree array

should_ne = <<EOS
0
|-- 1
|-- 1
|-- 1
0
|-- 1
|   |-- 2
|   |   |-- v
|   |   |   |-- 4
|   |   |   |-- 4
|   |   |   |-- 4
|   |   |-- 3
|   |   |-- 3
|   |-- 2
|-- 1
0
EOS
