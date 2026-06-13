# NOTE: sort_quick.rb defines a top-level `sort(comparator, array)` method.
# Run this file independently to avoid method name collisions with other sort files.
require 'minitest/autorun'
load File.expand_path('../sort_quick.rb', __dir__)

class SortQuickTest < Minitest::Test
  ASCENDING  = ->(x, pivot) { x < pivot }
  DESCENDING = ->(x, pivot) { x > pivot }

  def test_sorts_ascending
    input = [5, 3, 8, 1, 9, 2, 7, 4, 6]
    assert_equal input.sort, sort(ASCENDING, input)
  end

  def test_sorts_descending
    input = [5, 3, 8, 1, 9, 2, 7, 4, 6]
    assert_equal input.sort.reverse, sort(DESCENDING, input)
  end

  def test_empty_array
    assert_equal [], sort(ASCENDING, [])
  end

  def test_single_element
    assert_equal [7], sort(ASCENDING, [7])
  end

  def test_two_elements_out_of_order
    assert_equal [1, 2], sort(ASCENDING, [2, 1])
  end

  def test_already_sorted
    assert_equal [1, 2, 3, 4, 5], sort(ASCENDING, [1, 2, 3, 4, 5])
  end

  def test_reverse_sorted
    assert_equal [1, 2, 3, 4, 5], sort(ASCENDING, [5, 4, 3, 2, 1])
  end

  def test_duplicates
    assert_equal [1, 2, 2, 3, 3], sort(ASCENDING, [3, 1, 2, 3, 2])
  end

  def test_large_array
    input = (1..100).to_a.shuffle
    assert_equal (1..100).to_a, sort(ASCENDING, input)
  end
end
