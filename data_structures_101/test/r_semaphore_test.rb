require 'minitest/autorun'
require_relative 'mock_tuple_space'
require_relative '../r_semaphore'

class RSemaphoreTest < Minitest::Test
  def setup
    @ts  = MockTupleSpace.new
    @sem = RSemaphore.create(@ts, :printer, 3)
  end

  def test_create_writes_n_permit_tuples
    permits = @ts.tuples.select { |t| t == [:rsemaphore, :printer] }
    assert_equal 3, permits.size
  end

  def test_down_removes_one_permit
    @sem.down
    permits = @ts.tuples.select { |t| t == [:rsemaphore, :printer] }
    assert_equal 2, permits.size
  end

  def test_up_restores_one_permit
    @sem.down
    @sem.up
    permits = @ts.tuples.select { |t| t == [:rsemaphore, :printer] }
    assert_equal 3, permits.size
  end

  def test_down_all_permits
    3.times { @sem.down }
    permits = @ts.tuples.select { |t| t == [:rsemaphore, :printer] }
    assert_equal 0, permits.size
  end

  def test_down_blocks_when_exhausted
    3.times { @sem.down }
    assert_raises(RuntimeError) { @sem.down }
  end

  def test_exists_returns_true_when_present
    assert RSemaphore.exists?(@ts, :printer)
  end

  def test_exists_returns_false_when_absent
    refute RSemaphore.exists?(@ts, :absent)
  end

  def test_find_shares_same_permit_pool
    other = RSemaphore.find(@ts, :printer)
    other.down
    permits = @ts.tuples.select { |t| t == [:rsemaphore, :printer] }
    assert_equal 2, permits.size
  end
end
