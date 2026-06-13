require 'minitest/autorun'
require_relative 'mock_tuple_space'
require_relative '../r_barrier'

class RBarrierTest < Minitest::Test
  def setup
    @ts      = MockTupleSpace.new
    @barrier = RBarrier.create(@ts, :gate, 2)
  end

  def test_create_writes_barrier_tuple
    tuples = @ts.tuples
    assert tuples.any? { |t| t == [:rbarrier, :gate, 2, 0] }
  end

  def test_exists_returns_true_when_present
    assert RBarrier.exists?(@ts, :gate)
  end

  def test_exists_returns_false_when_absent
    refute RBarrier.exists?(@ts, :missing)
  end

  def test_find_aliases_new
    found = RBarrier.find(@ts, :gate)
    assert_instance_of RBarrier, found
  end

  def test_wait_increments_count
    # In a real tuple space, read blocks until count==num. The mock returns nil
    # instead of blocking, so wait returns nil but still increments the count.
    @barrier.wait
    count_tuple = @ts.tuples.find { |t| t[0] == :rbarrier && t[1] == :gate }
    assert_equal 1, count_tuple[3], "arrival count should be 1 after first wait"
  end

  def test_wait_releases_when_all_arrived
    # With num=2, the second wait should find [:rbarrier, :gate, 2, 2] and return.
    # Simulate: manually increment count to 1 before the final wait.
    @ts.take([:rbarrier, :gate, nil, nil])
    @ts.write([:rbarrier, :gate, 2, 1])
    # This wait should succeed: increments to 2, then reads [:rbarrier, :gate, 2, 2].
    result = @barrier.wait
    assert_equal [:rbarrier, :gate, 2, 2], result
  end
end
