require 'minitest/autorun'
require_relative '../pancake_sort'

class PancakeSortTest < Minitest::Test
  def test_sorts_random_array
    input = [1, 4, 5, 2, 3, 8, 6, 7, 9, 0]
    assert_equal input.sort, input.pancake_sort!
  end

  def test_already_sorted
    input = [1, 2, 3, 4, 5]
    assert_equal [1, 2, 3, 4, 5], input.pancake_sort!
  end

  def test_reverse_sorted
    input = [5, 4, 3, 2, 1]
    assert_equal [1, 2, 3, 4, 5], input.pancake_sort!
  end

  def test_single_element
    assert_equal [42], [42].pancake_sort!
  end

  def test_two_elements_out_of_order
    assert_equal [1, 2], [2, 1].pancake_sort!
  end

  def test_duplicates
    input = [3, 1, 2, 3, 1]
    assert_equal input.sort, input.pancake_sort!
  end

  def test_sorts_in_place
    input = [3, 1, 2]
    result = input.pancake_sort!
    assert_same input, result
  end

  def test_large_array
    input = (1..50).to_a.shuffle
    assert_equal (1..50).to_a, input.pancake_sort!
  end
end
