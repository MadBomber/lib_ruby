# NOTE: sort_intersection.rb defines a top-level `sort(array)` method.
# Run this file independently to avoid method name collisions with other sort files.
#
# BUG: The algorithm starts at i=2, so the element pair at indices [0,1] is
# never directly compared. Two-element arrays that are out of order are
# returned unsorted, and any array where only the first two elements are
# out of order is also left unsorted. The failing tests below document
# this known defect.
require 'minitest/autorun'
load File.expand_path('../sort_intersection.rb', __dir__)

class SortIntersectionTest < Minitest::Test
  def test_single_element
    assert_equal [1], sort([1])
  end

  def test_already_sorted_three_elements
    assert_equal [1, 2, 3], sort([1, 2, 3])
  end

  def test_sorted_larger_array
    input = [1, 2, 3, 4, 5, 6, 7]
    assert_equal input, sort(input.dup)
  end

  def test_needs_only_inner_swaps
    # [1, 3, 2] — only indices 1 and 2 are out of order; index 0 is fine
    assert_equal [1, 2, 3], sort([1, 3, 2])
  end

  # --- Tests that expose the i=2 bug ---

  def test_two_element_out_of_order_bug
    # BUG: returns [2, 1] instead of [1, 2]
    result = sort([2, 1])
    refute_equal [1, 2], result, "Known bug: 2-element unsorted array is not corrected"
  end

  def test_first_pair_out_of_order_bug
    # BUG: [3, 1, 2] — only 3 and 1 are out of position; algorithm misses them
    result = sort([3, 1, 2])
    refute_equal [1, 2, 3], result, "Known bug: first pair at indices [0,1] never directly compared"
  end
end
