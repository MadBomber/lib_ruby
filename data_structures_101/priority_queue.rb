require_relative 'min_heap'

# A priority queue that extracts priority from items via a block.
# Lower priority values surface first (min-priority semantics).
# Items with equal priority are returned in FIFO insertion order.
#
# Example:
#   pq = PriorityQueue.new { |job| job[:deadline] }
#   pq.push({ name: "A", deadline: 3 })
#   pq.push({ name: "B", deadline: 1 })
#   pq.pop  # => { name: "B", deadline: 1 }
#
# Complexity: same as MinHeap — O(log n) push/pop, O(1) peek.
class PriorityQueue
  Entry = Struct.new(:priority, :seq, :item)

  def initialize(&block)
    raise ArgumentError, "a priority block is required" unless block
    @heap     = []
    @priority = block
    @seq      = 0
  end

  # Build from a list of items. Requires the same priority block.
  def self.[](*items, &block)
    pq = new(&block)
    items.each { |item| pq.push(item) }
    pq
  end

  def push(item)
    @seq += 1
    @heap.push(Entry.new(@priority.call(item), @seq, item))
    sift_up(@heap.size - 1)
    self
  end

  def pop
    return nil if @heap.empty?
    top  = @heap[0]
    last = @heap.pop
    unless @heap.empty?
      @heap[0] = last
      sift_down(0)
    end
    top.item
  end

  def peek   = @heap.first&.item
  def size   = @heap.size
  def empty? = @heap.empty?

  private

  def less?(a, b)
    a.priority < b.priority || (a.priority == b.priority && a.seq < b.seq)
  end

  def sift_up(i)
    while i > 0
      parent = (i - 1) / 2
      break if less?(@heap[parent], @heap[i])
      @heap[parent], @heap[i] = @heap[i], @heap[parent]
      i = parent
    end
  end

  def sift_down(i)
    loop do
      left   = 2 * i + 1
      right  = 2 * i + 2
      target = i

      target = left  if left  < @heap.size && less?(@heap[left],  @heap[target])
      target = right if right < @heap.size && less?(@heap[right], @heap[target])

      break if target == i
      @heap[target], @heap[i] = @heap[i], @heap[target]
      i = target
    end
  end
end
