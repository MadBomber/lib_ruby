#!/usr/bin/env ruby

require 'minitest/autorun'
require_relative '../rangify'

class RangifyTest < Minitest::Test

  def test_simple_consecutive_range
    input = [1, 2, 3, 4, 5]
    expected = [1..5]
    assert_equal expected, rangify(input)
  end

  def test_single_numbers
    input = [1, 3, 5, 7]
    expected = [1, 3, 5, 7]
    assert_equal expected, rangify(input)
  end

  def test_mixed_ranges_and_singles
    input = [1, 2, 3, 5, 7, 8, 10]
    expected = [1..3, 5, 7..8, 10]
    assert_equal expected, rangify(input)
  end

  def test_unsorted_input
    input = [5, 1, 3, 2, 4]
    expected = [1..5]
    assert_equal expected, rangify(input)
  end

  def test_duplicates_removed
    input = [1, 1, 2, 2, 3, 3, 4, 4]
    expected = [1..4]
    assert_equal expected, rangify(input)
  end

  def test_single_element
    input = [42]
    expected = [42]
    assert_equal expected, rangify(input)
  end

  def test_two_consecutive_elements
    input = [1, 2]
    expected = [1..2]
    assert_equal expected, rangify(input)
  end

  def test_negative_numbers
    input = [-3, -2, -1, 0, 1]
    expected = [(-3..1)]
    assert_equal expected, rangify(input)
  end

  def test_gaps_in_sequence
    input = [1, 2, 4, 5, 6, 10, 11, 15]
    expected = [1..2, 4..6, 10..11, 15]
    assert_equal expected, rangify(input)
  end

  def test_empty_array
    input = []
    expected = []
    assert_equal expected, rangify(input)
  end

end

class UnrangifyTest < Minitest::Test

  def test_single_range
    input = [1..5]
    expected = [1, 2, 3, 4, 5]
    assert_equal expected, unrangify(input)
  end

  def test_single_numbers
    input = [1, 3, 5]
    expected = [1, 3, 5]
    assert_equal expected, unrangify(input)
  end

  def test_mixed_ranges_and_singles
    input = [1..3, 5, 7..8, 10]
    expected = [1, 2, 3, 5, 7, 8, 10]
    assert_equal expected, unrangify(input)
  end

  def test_multiple_ranges
    input = [1..3, 10..12, 20..21]
    expected = [1, 2, 3, 10, 11, 12, 20, 21]
    assert_equal expected, unrangify(input)
  end

  def test_negative_range
    input = [-3..0]
    expected = [-3, -2, -1, 0]
    assert_equal expected, unrangify(input)
  end

  def test_empty_array
    input = []
    expected = []
    assert_equal expected, unrangify(input)
  end

  def test_single_element_range
    input = [5..5]
    expected = [5]
    assert_equal expected, unrangify(input)
  end

  def test_roundtrip_conversion
    original = [1, 2, 3, 5, 7, 8, 10, 11, 12]
    ranged = rangify(original)
    restored = unrangify(ranged)
    assert_equal original.sort.uniq, restored
  end

  def test_roundtrip_with_duplicates_and_unsorted
    original = [5, 1, 3, 2, 4, 3, 8, 7, 1]
    ranged = rangify(original)
    restored = unrangify(ranged)
    expected = original.sort.uniq
    assert_equal expected, restored
  end

end