require 'minitest/autorun'
require_relative '../hyper_log_log'

class HyperLogLogTest < Minitest::Test
  def test_empty_count_is_zero
    assert_equal 0, HyperLogLog.new.count.round
  end

  def test_single_element
    hll = HyperLogLog.new
    hll.add("hello")
    assert_in_delta 1, hll.count, 1
  end

  def test_counts_distinct_elements
    hll = HyperLogLog.new
    100.times { |i| hll.add("item_#{i}") }
    assert_in_delta 100, hll.count, 10
  end

  def test_duplicates_not_double_counted
    hll = HyperLogLog.new
    50.times { hll.add("same") }
    assert_in_delta 1, hll.count, 1
  end

  def test_large_cardinality
    hll = HyperLogLog.new
    10_000.times { |i| hll.add("element_#{i}") }
    assert_in_delta 10_000, hll.count, 500
  end

  def test_add_returns_self
    hll = HyperLogLog.new
    assert_same hll, hll.add("a")
  end

  def test_shovel_operator_chains
    hll = HyperLogLog.new
    hll << "a" << "b" << "c"
    assert_in_delta 3, hll.count, 1
  end

  def test_merge_combines_disjoint_sets
    hll1 = HyperLogLog.new
    hll2 = HyperLogLog.new
    50.times { |i| hll1.add("a_#{i}") }
    50.times { |i| hll2.add("b_#{i}") }
    assert_in_delta 100, hll1.merge(hll2).count, 10
  end

  def test_merge_with_overlapping_sets
    hll1 = HyperLogLog.new
    hll2 = HyperLogLog.new
    100.times { |i| hll1.add("item_#{i}") }
    100.times { |i| hll2.add("item_#{i}") }
    assert_in_delta 100, hll1.merge(hll2).count, 10
  end

  def test_merge_does_not_modify_originals
    hll1 = HyperLogLog.new
    hll2 = HyperLogLog.new
    hll1.add("a")
    hll2.add("b")
    before1 = hll1.count
    before2 = hll2.count
    hll1.merge(hll2)
    assert_in_delta before1, hll1.count, 0.001
    assert_in_delta before2, hll2.count, 0.001
  end

  def test_merge_bang_modifies_in_place
    hll1 = HyperLogLog.new
    hll2 = HyperLogLog.new
    50.times { |i| hll1.add("a_#{i}") }
    50.times { |i| hll2.add("b_#{i}") }
    result = hll1.merge!(hll2)
    assert_same hll1, result
    assert_in_delta 100, hll1.count, 10
  end

  def test_merge_raises_on_precision_mismatch
    hll1 = HyperLogLog.new(precision: 10)
    hll2 = HyperLogLog.new(precision: 12)
    assert_raises(ArgumentError) { hll1.merge(hll2) }
    assert_raises(ArgumentError) { hll1.merge!(hll2) }
  end

  def test_invalid_precision_raises
    assert_raises(ArgumentError) { HyperLogLog.new(precision: 3) }
    assert_raises(ArgumentError) { HyperLogLog.new(precision: 17) }
  end

  def test_accepts_mixed_types
    hll = HyperLogLog.new
    hll.add(42)
    hll.add(:symbol)
    hll.add([1, 2, 3])
    assert_in_delta 3, hll.count, 1
  end

  def test_size_matches_precision
    assert_equal 1024, HyperLogLog.new(precision: 10).size
    assert_equal 16_384, HyperLogLog.new(precision: 14).size
  end

  def test_low_precision_is_less_accurate_but_works
    hll = HyperLogLog.new(precision: 4)
    1_000.times { |i| hll.add("x_#{i}") }
    assert_in_delta 1_000, hll.count, 300
  end

  def test_same_element_added_from_two_counters_counts_once
    hll1 = HyperLogLog.new
    hll2 = HyperLogLog.new
    hll1.add("shared")
    hll2.add("shared")
    merged = hll1.merge(hll2)
    assert_in_delta 1, merged.count, 1
  end
end
