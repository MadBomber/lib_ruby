#!/usr/bin/env ruby

require 'minitest/autorun'
require_relative '../time_this'

class TimeThisTest < Minitest::Test

  def test_returns_numeric_time
    elapsed = time_this { sleep 0.001 }
    assert_kind_of Numeric, elapsed
    assert elapsed > 0
  end

  def test_measures_sleep_accurately
    sleep_duration = 0.01
    elapsed = time_this { sleep sleep_duration }
    
    # Allow some tolerance for system scheduling
    assert elapsed >= sleep_duration * 0.8, "Elapsed time too short: #{elapsed}"
    assert elapsed <= sleep_duration * 2.0, "Elapsed time too long: #{elapsed}"
  end

  def test_measures_zero_time_for_instant_operation
    elapsed = time_this { 1 + 1 }
    assert elapsed >= 0
    # Should be very small for simple arithmetic
    assert elapsed < 0.01, "Simple operation took too long: #{elapsed}"
  end

  def test_returns_value_from_block_implicitly
    # The function doesn't return block value, only timing
    result = time_this { "hello world" }
    assert_kind_of Numeric, result
    refute_equal "hello world", result
  end

  def test_handles_block_with_return_value
    elapsed = time_this do
      x = 0
      1000.times { x += 1 }
      x
    end
    assert_kind_of Numeric, elapsed
    assert elapsed > 0
  end

  def test_measures_different_operations
    quick_time = time_this { 1 + 1 }
    slow_time = time_this { sleep 0.001 }
    
    assert slow_time > quick_time, "Sleep should take longer than arithmetic"
  end

  def test_handles_exception_in_block
    assert_raises StandardError do
      time_this { raise StandardError, "test error" }
    end
  end

  def test_precision_with_very_short_operations
    # Test that it can measure very short operations
    elapsed = time_this do
      1000.times { Math.sqrt(100) }
    end
    
    assert elapsed > 0, "Should measure some time even for fast operations"
    assert elapsed < 1.0, "1000 sqrt operations shouldn't take more than 1 second"
  end

  def test_monotonic_clock_usage
    # Test that successive calls show increasing precision
    times = []
    5.times do
      times << time_this { sleep 0.001 }
    end
    
    # All times should be positive
    times.each { |t| assert t > 0 }
    
    # Should be relatively consistent (within 50% variance)
    avg = times.sum / times.length
    times.each do |t|
      assert (t - avg).abs / avg < 0.5, "Time variance too high: #{times}"
    end
  end

  def test_nested_timing
    outer_time = time_this do
      inner_time = time_this { sleep 0.001 }
      sleep 0.001
      # inner_time is available but outer measurement includes both sleeps
    end
    
    # Outer time should be roughly double inner sleep time
    assert outer_time >= 0.0015, "Outer time should include both sleeps"
  end

  def test_block_required
    assert_raises(LocalJumpError) do
      time_this  # No block provided
    end
  end

  def test_works_with_complex_blocks
    elapsed = time_this do
      arr = []
      100.times do |i|
        arr << i * 2
      end
      arr.sum
    end
    
    assert_kind_of Numeric, elapsed
    assert elapsed > 0
  end

end