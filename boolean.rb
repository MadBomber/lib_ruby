# ~/lib/ruby/boolean.rb
#
# Could this be a good subsitute for the lack of a Boolean
# class in Ruby?
#
# It restricts logical operations to boolean types.

module BooleanExtensions
  # Define logical operations in a module

  # Return 1 for true and 0 for false
  def to_i
    self ? 1 : 0
  end

  # Return "true" or "false"
  def to_s
    self ? 'true' : 'false'
  end

  def and(other)
    self && other.to_b
  end

  def or(other)
    self || other.to_b
  end

  def not
    !self
  end

  def xor(other)
    self ^ other.to_b
  end

  # Redefining | & ^ ! to maintain consistency and return Boolean values
  def |(other)
    self || other.to_b
  end

  def &(other)
    self && other.to_b
  end

  def ^(other)
    self ^ other.to_b
  end

  # def !
  #   !self
  # end

  # Add the is_a? override to inclusively recognize Boolean
  def is_a?(klass)
    [Boolean, TrueClass, FalseClass].include? klass
  end  
end

# Extend TrueClass and FalseClass with our module
TrueClass.include(BooleanExtensions)
FalseClass.include(BooleanExtensions)

# Redefined Boolean class
class Boolean
  def self.true
    true
  end

  def self.false
    false
  end

  # Return 1 for true and 0 for false
  def to_i
    self ? 1 : 0
  end

  # Return "true" or "false"
  def to_s
    self ? 'true' : 'false'
  end

  # Direct invocation of new is not meaningful now
  private_class_method :new
end


# Extending Kernel with new functionality
module Kernel
  def to_boolean
    case self
    when Boolean
      self
    when TrueClass
      Boolean.true
    when FalseClass
      Boolean.false
    else
      raise TypeError.new("Cannot convert #{self.class} to Boolean")
    end
  end

  alias_method :to_b, :to_boolean
end
