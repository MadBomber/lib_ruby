require 'minitest/autorun'
require_relative '../min_heap'

class MinHeapTest < Minitest::Test
  def test_empty_on_creation
    heap = MinHeap.new
    assert heap.empty?
    assert_equal 0, heap.size
  end

  def test_peek_returns_nil_when_empty
    assert_nil MinHeap.new.peek
  end

  def test_pop_returns_nil_when_empty
    assert_nil MinHeap.new.pop
  end

  def test_push_single_item
    heap = MinHeap.new
    heap.push(42)
    refute heap.empty?
    assert_equal 1, heap.size
    assert_equal 42, heap.peek
  end

  def test_push_returns_self_for_chaining
    heap = MinHeap.new
    result = heap.push(1)
    assert_same heap, result
  end

  def test_pop_single_item
    heap = MinHeap.new
    heap.push(7)
    assert_equal 7, heap.pop
    assert heap.empty?
  end

  def test_pop_returns_minimum
    heap = MinHeap.new
    [5, 3, 8, 1, 9, 2].each { |n| heap.push(n) }
    assert_equal 1, heap.pop
    assert_equal 2, heap.pop
    assert_equal 3, heap.pop
  end

  def test_drain_in_sorted_order
    items = [5, 3, 8, 1, 9, 2, 7, 4, 6]
    heap  = MinHeap.new
    items.each { |n| heap.push(n) }
    result = []
    result << heap.pop until heap.empty?
    assert_equal items.sort, result
  end

  def test_peek_does_not_remove
    heap = MinHeap.new
    heap.push(3).push(1).push(2)
    assert_equal 1, heap.peek
    assert_equal 3, heap.size
  end

  def test_build_from_items_class_method
    heap = MinHeap[5, 3, 8, 1, 9, 2]
    assert_equal 6, heap.size
    assert_equal 1, heap.peek
  end

  def test_build_drains_in_sorted_order
    items = [5, 3, 8, 1, 9, 2, 7, 4, 6]
    heap  = MinHeap[*items]
    result = []
    result << heap.pop until heap.empty?
    assert_equal items.sort, result
  end

  def test_to_a_does_not_modify_heap
    heap = MinHeap[3, 1, 2]
    arr  = heap.to_a
    assert_equal 3, heap.size
    assert_instance_of Array, arr
  end

  def test_handles_duplicate_values
    heap = MinHeap.new
    [4, 2, 4, 1, 2].each { |n| heap.push(n) }
    assert_equal 1, heap.pop
    assert_equal 2, heap.pop
    assert_equal 2, heap.pop
    assert_equal 4, heap.pop
    assert_equal 4, heap.pop
    assert heap.empty?
  end

  def test_handles_single_element_pop
    heap = MinHeap.new
    heap.push(99)
    assert_equal 99, heap.pop
    assert heap.empty?
  end

  def test_works_with_strings
    heap = MinHeap.new
    %w[banana apple cherry date].each { |s| heap.push(s) }
    assert_equal "apple",  heap.pop
    assert_equal "banana", heap.pop
    assert_equal "cherry", heap.pop
    assert_equal "date",   heap.pop
  end

  def test_interleaved_push_and_pop
    heap = MinHeap.new
    heap.push(5).push(3)
    assert_equal 3, heap.pop
    heap.push(1).push(4)
    assert_equal 1, heap.pop
    assert_equal 4, heap.pop
    assert_equal 5, heap.pop
    assert heap.empty?
  end
end
