# ~/lib/ruby/bit_matrix.rb

# encoding: utf-8
# frozen_string_literal: true
# warn_indent: true
##########################################################
###
##  File: bit_ matrix.rb
##  Desc: A way to represent an undirected graph
#
# See: http://tenderlovemaking.com/2023/03/19/bitmap-matrix-and-undirected-graphs-in-ruby.html
#


# A square matrix of a given size in which the value one represents a connection 
# connection between the row and column number.  A zero means no connection. The
# matrix is a dense collection of bits.
#
class BitMatrix
  def initialize(size)
    raise(IndexError, "size must be positive numeric") if (size <= 0)
    @size = size.to_i
    size = ((size + 7) & -8)
    @row_bytes = (size / 8)
    @buffer = ("\x00".b * (@row_bytes * size))
  end

  def initialize_copy(other)
    @buffer = @buffer.dup
  end

  def validate_x_y(x, y)
    raise(IndexError, "x must be >= #{@size}") if (x >= @size)
    raise(IndexError, "y must be >= #{@size}") if (y >= @size)
  end

  def set(x, y)
    validate_x_y(x, y)
    x, y = [y, x].sort
    row = (x * @row_bytes)
    column_byte = (y / 8)
    column_bit = (1 << (y % 8))
    @buffer.setbyte((row + column_byte), (@buffer.getbyte((row + column_byte)) | column_bit))
  end

  def set?(x, y)
    validate_x_y(x, y)
    x, y = [y, x].sort
    row = (x * @row_bytes)
    column_byte = (y / 8)
    column_bit = (1 << (y % 8))
    ((@buffer.getbyte((row + column_byte)) & column_bit) != 0)
  end

  def each_pair
    return enum_for(:each_pair) unless block_given?
    @buffer.bytes.each_with_index do |byte, i|
      row = (i / @row_bytes)
      column = (i % @row_bytes)
      8.times { |j| yield([row, ((column * 8) + j)]) if (((1 << j) & byte) != 0) }
    end
  end

  def to_dot
    (("graph g {\n" + each_pair.map { |x, y| "#{x} -- #{y};" }.join("\n")) + "\n}")
  end
end
