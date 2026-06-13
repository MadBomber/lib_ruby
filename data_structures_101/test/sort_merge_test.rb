# NOTE: sort_merge.rb defines top-level `sort` and `merge` methods.
# Run this file independently — loading multiple sort files in the same
# process will cause method name collisions.
require 'minitest/autorun'
load File.expand_path('../sort_merge.rb', __dir__)

class SortMergeTest < Minitest::Test
  def test_sorts_random_array
    input = [5, 3, 8, 1, 9, 2, 7, 4, 6]
    assert_equal input.sort, sort(input)
  end

  def test_already_sorted
    assert_equal [1, 2, 3], sort([1, 2, 3])
  end

  def test_reverse_sorted
    assert_equal [1, 2, 3, 4, 5], sort([5, 4, 3, 2, 1])
  end

  def test_single_element
    assert_equal [42], sort([42])
  end

  def test_two_elements_in_order
    assert_equal [1, 2], sort([1, 2])
  end

  def test_two_elements_out_of_order
    assert_equal [1, 2], sort([2, 1])
  end

  def test_duplicates
    assert_equal [1, 2, 2, 3, 3], sort([3, 1, 2, 3, 2])
  end

  def test_large_array
    input = (1..100).to_a.shuffle
    assert_equal (1..100).to_a, sort(input)
  end

  def test_merge_two_sorted_arrays
    assert_equal [1, 2, 3, 4], merge([1, 3], [2, 4])
  end

  def test_merge_empty_left
    assert_equal [1, 2, 3], merge([], [1, 2, 3])
  end

  def test_merge_empty_right
    assert_equal [1, 2, 3], merge([1, 2, 3], [])
  end
end
