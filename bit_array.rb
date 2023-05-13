# ~/lib/ruby/bit_array.rb
# frozen_string_literal: true
# warn_indent: true
##########################################################
###
##  File: bit_array.rb
##  Desc: Represent an Array of bits in an integer
##  By:   Dewayne VanHoozer (dvanhoozer@gmail.com)
#

# The BitArray class provides a simple way to manipulate a 
# fixed-size array of bits.

class BitArray
  attr_accessor :bits
  attr_reader   :size


  # Initializes a new BitArray instance with the specified size.
  #
  # @param size [Integer] the size of the bit array
  def initialize(size)
    @bits = 0
    @size = size
  end


  ############################################
  ## Methods that Change the Value of Bit(s)

  # Turns one or more bits on.
  #
  # @param indexes [Integer, Array<Integer>] the index or array of indexes to turn on
  def on!(indexes)
    Array(indexes).each do |index|
      validate_index(index)
      @bits |= (1 << index)
    end
  end


  # Turns one or more bits off.
  #
  # @param indexes [Integer, Array<Integer>] the index or array of indexes to turn off
  def off!(indexes)
    Array(indexes).each do |index|
      validate_index(index)
      @bits &= ~(1 << index)
    end
  end


  # Alias for off! method.
  alias_method :clear!, :off!


  # Toggles one or more bits.
  #
  # @param indexes [Integer, Array<Integer>] the index or array of indexes to toggle
  def toggle!(indexes)
    Array(indexes).each do |index|
      validate_index(index)
      @bits ^= (1 << index)
    end
  end


  ############################################
  ## Methods that Query the Value of Bit(s)

  # Checks if a bit is off.
  #
  # @param indexes [Array of Integers] the indexes of the bits to check
  # @return [Boolean] true if the specified bits are off, false otherwise
  def off?(indexes)
    !on?(indexes)
  end


  # Checks if any of the specified bits are on.
  #
  # @param indexes [Array<Integer>] the array of indexes to check
  # @return [Boolean] true if any of the specified bits are on, false otherwise
  def any?(indexes = (0...@size).to_a)
    indexes.any? do |index| 
      validate_index(index)
      bit_on?(index)
    end
  end


  # Checks if all of the specified bits are on.
  #
  # @param indexes [Array<Integer>] the array of indexes to check
  # @return [Boolean] true if all of the specified bits are on, false otherwise
  def all?(indexes = (0...@size).to_a)
    Array(indexes).all? do |index| 
      validate_index(index)
      bit_on?(index)
    end
  end

  # Alias for all? method.
  alias_method :on?,  :all? 

  # Alias for all? method.
  alias_method :set?, :all?


  # Returns an array of indexes to bits that are on.
  #
  # @return [Array<Integer>] the array of indexes to bits that are on
  def available
    (0...@size).select { |index| bit_on?(index) }
  end

  # Alias for available method.
  alias_method :free, :available


  # Returns an array of indexes to bits that are off.
  #
  # @return [Array<Integer>] the array of indexes to bits that are off
  def not_available
    (0...@size).reject { |index| bit_on?(index) }
  end

  # Alias for not_available method.
  alias_method :booked, :not_available


  ###############################################
  private

  def bit_on?(index)
    validate_index(index)
    (@bits & (1 << index)) != 0
  end

  def validate_index(index)
    raise "Index must be an integer" unless index.is_a?(Integer)
    raise "Index out of range" if index < 0 || index >= @size
  end
end

