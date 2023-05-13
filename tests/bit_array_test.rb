#!/usr/bin/env ruby

require 'minitest/autorun'
require_relative '../bit_array'

class TestBitArray < Minitest::Test
  def setup
    @bit_array = BitArray.new(8)
  end

  def test_on
    @bit_array.on!(0)
    assert @bit_array.on?(0)
    refute @bit_array.off?(0)

    @bit_array.on!([2, 4])
    assert @bit_array.on?([0, 2, 4])
    refute @bit_array.off?([0, 2, 4])
  end

  def test_off
    @bit_array.on!([0, 2, 4])
    @bit_array.off!(0)
    refute @bit_array.on?(0)
    assert @bit_array.off?(0)

    @bit_array.off!([2, 4])
    refute @bit_array.on?([0, 2, 4])
    assert @bit_array.off?([0, 2, 4])
  end

  def test_toggle
    @bit_array.toggle!(0)
    assert @bit_array.on?(0)
    assert @bit_array.off?(2)
    assert @bit_array.off?(4)

    @bit_array.toggle!([2, 4])

    assert @bit_array.on?(2)
    assert @bit_array.on?(4)
  end

  def test_all
    @bit_array.on!([0, 2, 4])
    assert @bit_array.all?([0, 2, 4])
    refute @bit_array.all?([0, 2, 5])
  end

  def test_any
    @bit_array.on!([0, 2, 4])
    assert @bit_array.any?([0, 2, 5])
    refute @bit_array.any?([1, 3, 5])
  end

  def test_available
    @bit_array.on!([0, 2, 4])
    assert_equal [0, 2, 4], @bit_array.available
    assert_equal [1, 3, 5, 6, 7], @bit_array.not_available
    assert_equal [0, 2, 4], @bit_array.free
    assert_equal [1, 3, 5, 6, 7], @bit_array.booked
  end

  def test_bits
    assert_equal [], @bit_array.free 

    @bit_array.bits = 42

    assert_equal [1, 3, 5], @bit_array.free 
    assert @bit_array.on? [1, 3, 5]

    @bit_array.toggle! [1, 3, 5]
    assert_equal 0, @bit_array.bits
  end


  def test_out_of_range
    assert_raises(RuntimeError) { @bit_array.on!(8) }
    assert_raises(RuntimeError) { @bit_array.off!(8) }
    assert_raises(RuntimeError) { @bit_array.toggle!(8) }
    assert_raises(RuntimeError) { @bit_array.on?(-1) }
    assert_raises(RuntimeError) { @bit_array.off?(-1) }
  end
end



