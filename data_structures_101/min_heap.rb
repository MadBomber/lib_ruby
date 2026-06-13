# A min-heap backed by an array. The smallest item is always at the top.
# Items must be Comparable with each other.
#
# Complexity:
#   push  — O(log n)
#   pop   — O(log n)
#   peek  — O(1)
#   build via MinHeap[*items] — O(n)
class MinHeap
  def initialize
    @items = []
  end

  # Build a heap from a list of items in O(n) time.
  def self.[](*items)
    heap = allocate
    heap.send(:initialize)
    heap.instance_variable_set(:@items, items.dup)
    last_parent = (items.size - 2) / 2
    last_parent.downto(0) { |i| heap.send(:sift_down, i) } if items.size > 1
    heap
  end

  def push(item)
    @items.push(item)
    sift_up(@items.size - 1)
    self
  end

  def pop
    return nil if @items.empty?
    min  = @items[0]
    last = @items.pop
    unless @items.empty?
      @items[0] = last
      sift_down(0)
    end
    min
  end

  def peek   = @items.first
  def size   = @items.size
  def empty? = @items.empty?
  def to_a   = @items.dup

  private

  def sift_up(i)
    while i > 0
      parent = (i - 1) / 2
      break if @items[parent] <= @items[i]
      @items[parent], @items[i] = @items[i], @items[parent]
      i = parent
    end
  end

  def sift_down(i)
    loop do
      left   = 2 * i + 1
      right  = 2 * i + 2
      target = i

      target = left  if left  < @items.size && @items[left]  < @items[target]
      target = right if right < @items.size && @items[right] < @items[target]

      break if target == i
      @items[target], @items[i] = @items[i], @items[target]
      i = target
    end
  end
end
