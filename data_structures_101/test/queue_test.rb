require 'minitest/autorun'
require_relative 'mock_tuple_space'
require_relative '../queue'

class QueueTest < Minitest::Test
  def setup
    @ts    = MockTupleSpace.new
    @queue = Queue.create(@ts, :test_queue)
  end

  def test_create_initializes_head_and_tail
    tuples = @ts.tuples
    assert tuples.any? { |t| t[0] == :queue && t[1] == :tail && t[2] == :test_queue && t[3] == 0 }
    assert tuples.any? { |t| t[0] == :queue && t[1] == :head && t[2] == :test_queue && t[3] == 1 }
  end

  def test_send_stores_data
    @queue.send("hello")
    tuples = @ts.tuples
    assert tuples.any? { |t| t[0] == :queue && t[2] == 1 && t[3] == "hello" }
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

  def test_send_and_read_multiple_types
    @queue.send(42)
    @queue.send(:symbol)
    @queue.send([1, 2, 3])
    assert_equal 42,        @queue.read
    assert_equal :symbol,   @queue.read
    assert_equal [1, 2, 3], @queue.read
  end

  def test_find_returns_existing_queue
    found = Queue.find(@ts, :test_queue)
    found.send("via_find")
    assert_equal "via_find", @queue.read
  end
end
