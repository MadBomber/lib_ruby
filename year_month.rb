###############################################
###
##  File: year_month.rb
##  Desc: http://blog.arkency.com/2014/08/using-ruby-range-with-custom-classes
#

class YearMonth < Struct.new(:year, :month)
  include Comparable

  def initialize(year, month)
    raise ArgumentError unless Fixnum === year
    raise ArgumentError unless Fixnum === month
    raise ArgumentError unless year > 0
    raise ArgumentError unless month >= 1 && month <= 12

    super
  end

  def next
    if month == 12
      self.class.new(year+1, 1)
    else
      self.class.new(year, month+1)
    end
  end
  alias_method :succ, :next

  def <=>(other)
    (year <=> other.year).nonzero? || month <=> other.month
  end

  def beginning_of
    Time.new(year, month, 1)
  end

  def end_of
    beginning_of.end_of_month
  end

  private :year=, :month=
end
