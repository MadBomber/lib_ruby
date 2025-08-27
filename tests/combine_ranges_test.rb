#!/usr/bin/env ruby

require 'minitest/autorun'
require_relative '../combine_ranges'

class CombineRangesTest < Minitest::Test

  def test_no_overlapping_ranges
    input = [[1, 2], [4, 5], [7, 8]]
    expected = [[1, 2], [4, 5], [7, 8]]
    assert_equal expected, combine_ranges(input)
  end

  def test_overlapping_ranges
    input = [[1, 3], [2, 6], [8, 10], [15, 18]]
    expected = [[1, 6], [8, 10], [15, 18]]
    assert_equal expected, combine_ranges(input)
  end

  def test_adjacent_ranges_get_combined
    # Adjacent ranges (where one ends at N and next starts at N+1) should combine
    input = [[1, 4], [5, 6]]
    expected = [[1, 6]]
    assert_equal expected, combine_ranges(input)
  end

  def test_completely_overlapping_ranges
    input = [[1, 10], [3, 7]]
    expected = [[1, 10]]
    assert_equal expected, combine_ranges(input)
  end

  def test_single_range
    input = [[1, 5]]
    expected = [[1, 5]]
    assert_equal expected, combine_ranges(input)
  end

  def test_unsorted_input_gets_sorted
    input = [[6, 7], [1, 3], [4, 5]]
    expected = [[1, 7]]  # All should combine since 1-3, 4-5, 6-7 are adjacent
    assert_equal expected, combine_ranges(input)
  end

  def test_multiple_overlaps
    input = [[1, 4], [2, 5], [3, 6], [8, 10]]
    expected = [[1, 6], [8, 10]]
    assert_equal expected, combine_ranges(input)
  end

  def test_touching_ranges
    input = [[1, 2], [3, 4], [5, 6]]
    expected = [[1, 6]]  # All touching should combine
    assert_equal expected, combine_ranges(input)
  end

  def test_negative_numbers
    input = [[-5, -3], [-2, 0], [1, 3]]
    expected = [[-5, 0], [1, 3]]
    assert_equal expected, combine_ranges(input)
  end

  def test_large_gaps
    input = [[1, 2], [100, 101]]
    expected = [[1, 2], [100, 101]]
    assert_equal expected, combine_ranges(input)
  end

  def test_identical_ranges
    input = [[1, 3], [1, 3], [1, 3]]
    expected = [[1, 3]]
    assert_equal expected, combine_ranges(input)
  end

  def test_nested_ranges
    input = [[1, 10], [2, 3], [4, 5], [6, 9]]
    expected = [[1, 10]]
    assert_equal expected, combine_ranges(input)
  end

  def test_single_point_ranges
    input = [[1, 1], [2, 2], [3, 3]]
    expected = [[1, 3]]
    assert_equal expected, combine_ranges(input)
  end

  def test_zero_ranges
    input = [[0, 0], [1, 1]]
    expected = [[0, 1]]
    assert_equal expected, combine_ranges(input)
  end

  def test_large_numbers
    input = [[1000, 1005], [1007, 1010], [2000, 2005]]
    expected = [[1000, 1005], [1007, 1010], [2000, 2005]]
    assert_equal expected, combine_ranges(input)
  end

  def test_ranges_that_exactly_touch
    input = [[1, 5], [6, 10], [11, 15]]
    expected = [[1, 15]]
    assert_equal expected, combine_ranges(input)
  end

end