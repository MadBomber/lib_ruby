require 'minitest/autorun'
require_relative '../priority_queue'

class DS101PriorityQueueTest < Minitest::Test
  Job = Struct.new(:name, :deadline)

  def setup
    @pq = PriorityQueue.new { |job| job.deadline }
  end

  def test_requires_a_block
    assert_raises(ArgumentError) { PriorityQueue.new }
  end

  def test_empty_on_creation
    assert @pq.empty?
    assert_equal 0, @pq.size
  end

  def test_peek_returns_nil_when_empty
    assert_nil @pq.peek
  end

  def test_pop_returns_nil_when_empty
    assert_nil @pq.pop
  end

  def test_push_single_item
    job = Job.new("A", 5)
    @pq.push(job)
    refute @pq.empty?
    assert_equal 1, @pq.size
    assert_equal job, @pq.peek
  end

  def test_push_returns_self_for_chaining
    result = @pq.push(Job.new("A", 1))
    assert_same @pq, result
  end

  def test_pop_returns_lowest_priority_first
    @pq.push(Job.new("A", 5))
    @pq.push(Job.new("B", 1))
    @pq.push(Job.new("C", 3))
    assert_equal "B", @pq.pop.name
    assert_equal "C", @pq.pop.name
    assert_equal "A", @pq.pop.name
  end

  def test_drain_returns_items_in_priority_order
    jobs = [Job.new("A", 5), Job.new("B", 1), Job.new("C", 3), Job.new("D", 2), Job.new("E", 4)]
    jobs.each { |j| @pq.push(j) }
    names = []
    names << @pq.pop.name until @pq.empty?
    assert_equal %w[B D C E A], names
  end

  def test_fifo_ordering_for_equal_priorities
    @pq.push(Job.new("first",  2))
    @pq.push(Job.new("second", 2))
    @pq.push(Job.new("third",  2))
    assert_equal "first",  @pq.pop.name
    assert_equal "second", @pq.pop.name
    assert_equal "third",  @pq.pop.name
  end

  def test_peek_does_not_remove
    @pq.push(Job.new("A", 3))
    @pq.push(Job.new("B", 1))
    assert_equal "B", @pq.peek.name
    assert_equal 2, @pq.size
  end

  def test_class_method_constructor
    jobs = [Job.new("A", 3), Job.new("B", 1), Job.new("C", 2)]
    pq   = PriorityQueue[*jobs] { |j| j.deadline }
    assert_equal 3, pq.size
    assert_equal "B", pq.pop.name
  end

  def test_works_with_hash_items
    pq = PriorityQueue.new { |item| item[:score] }
    pq.push({ name: "low",    score: 10 })
    pq.push({ name: "high",   score: 1  })
    pq.push({ name: "medium", score: 5  })
    assert_equal "high",   pq.pop[:name]
    assert_equal "medium", pq.pop[:name]
    assert_equal "low",    pq.pop[:name]
  end

  def test_interleaved_push_and_pop
    @pq.push(Job.new("A", 5))
    @pq.push(Job.new("B", 2))
    assert_equal "B", @pq.pop.name
    @pq.push(Job.new("C", 1))
    @pq.push(Job.new("D", 3))
    assert_equal "C", @pq.pop.name
    assert_equal "D", @pq.pop.name
    assert_equal "A", @pq.pop.name
    assert @pq.empty?
  end
end
