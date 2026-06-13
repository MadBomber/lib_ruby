require 'minitest/autorun'
require_relative 'mock_tuple_space'
require_relative '../bounded_queue'

class BoundedQueueTest < Minitest::Test
  def setup
    @ts    = MockTupleSpace.new
    @queue = BoundedQueue.create(@ts, :bq, 3)
  end

  def test_create_initializes_status
    tuples = @ts.tuples
    status = tuples.find { |t| t[0] == :bqueue && t[1] == :status }
    assert status, "status tuple should exist"
    size, length, full, empty = status[2..5]
    assert_equal 3,     size
    assert_equal 0,     length
    assert_equal false, full
    assert_equal true,  empty
  end

  def test_send_single_item
    @queue.send("a")
    tuples = @ts.tuples
    assert tuples.any? { |t| t[0] == :bqueue && t[2] == 1 && t[3] == "a" }
  end

  def test_send_updates_length
    @queue.send("a")
    status = @ts.tuples.find { |t| t[0] == :bqueue && t[1] == :status }
    assert_equal 1, status[3]
  end

  def test_read_returns_sent_data
    @queue.send("hello")
    assert_equal "hello", @queue.read
  end

  def test_fifo_ordering
    @queue.send("first")
    @queue.send("second")
    @queue.send("third")
    assert_equal "first",  @queue.read
    assert_equal "second", @queue.read
    assert_equal "third",  @queue.read
  end

  def test_status_full_when_at_capacity
    3.times { |i| @queue.send(i) }
    status = @ts.tuples.find { |t| t[0] == :bqueue && t[1] == :status }
    assert_equal true, status[4], "queue should be full"
  end

  def test_send_blocks_when_full
    # The mock raises on missing tuple; a full queue's send will try to take
    # a status tuple with FULL=false, which won't exist.
    3.times { |i| @queue.send(i) }
    assert_raises(RuntimeError) { @queue.send("overflow") }
  end

  def test_read_blocks_when_empty
    assert_raises(RuntimeError) { @queue.read }
  end

  def test_status_empty_after_draining
    @queue.send("x")
    @queue.read
    status = @ts.tuples.find { |t| t[0] == :bqueue && t[1] == :status }
    assert_equal true, status[5], "queue should be empty"
  end

  def test_find_returns_existing_queue
    found = BoundedQueue.find(@ts, :bq)
    @queue.send("shared")
    assert_equal "shared", found.read
  end
end
