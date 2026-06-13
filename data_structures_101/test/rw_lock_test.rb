require 'minitest/autorun'
require_relative 'mock_tuple_space'
require_relative '../rw_lock'

class RWLockTest < Minitest::Test
  def setup
    @ts   = MockTupleSpace.new
    @lock = RWLock.create(@ts, :doc)
  end

  def tuple(label)
    @ts.tuples.find { |t| t[0] == :doc && t[1] == label }
  end

  def test_create_initializes_counters
    assert_equal(-1, tuple('dispenser')[2])
    assert_equal  0, tuple('reader')[2]
    assert_equal  0, tuple('turn')[2]
  end

  def test_exists_returns_true
    assert RWLock.exists?(@ts, :doc)
  end

  def test_exists_returns_false_for_unknown
    refute RWLock.exists?(@ts, :unknown)
  end

  def test_read_lock_increments_reader_and_advances_turn
    @lock.read_lock
    assert_equal 1, tuple('reader')[2],     "reader count should be 1"
    assert_equal 1, tuple('turn')[2],       "turn should advance to 1"
    assert_equal 0, tuple('dispenser')[2],  "dispenser should be 0 after first ticket"
  end

  def test_read_unlock_decrements_reader
    @lock.read_lock
    @lock.read_unlock
    assert_equal 0, tuple('reader')[2]
  end

  def test_write_lock_claims_turn_and_checks_no_readers
    # write_lock: inc dispenser (0), wait for turn==0 (present), read reader==0 (present)
    @lock.write_lock
    assert_equal 0, tuple('dispenser')[2]
    assert_nil tuple('turn'),   "write_lock takes the turn tuple, leaving none"
    assert_equal 0, tuple('reader')[2]
  end

  def test_write_unlock_advances_turn
    @lock.write_lock
    @lock.write_unlock
    assert_equal 1, tuple('turn')[2], "turn should advance to ticket+1 after write_unlock"
  end

  def test_sequential_read_write_read
    @lock.read_lock
    @lock.read_unlock
    @lock.write_lock
    @lock.write_unlock
    @lock.read_lock
    assert_equal 1, tuple('reader')[2]
  end
end
