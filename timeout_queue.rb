# timeout_queue.rb
# From: https://vaneyckt.io/posts/ruby_concurrency_building_a_timeout_queue/?utm_source=rubyweekly&utm_medium=email


class TimeoutQueue
  def initialize
    @elems = []
    @mutex = Mutex.new
    @cond_var = ConditionVariable.new
  end # def initialize

  def <<(elem)
    @mutex.synchronize do
      @elems << elem
      @cond_var.signal
    end
  end # def <<(elem)

  def pop(blocking = true, timeout = nil)
    @mutex.synchronize do
      if blocking
        if timeout.nil?
          while @elems.empty?
            @cond_var.wait(@mutex)
          end
        else
          timeout_time = Time.now.to_f + timeout
          while @elems.empty? &&
                (remaining_time = timeout_time - Time.now.to_f) > 0
            @cond_var.wait(@mutex, remaining_time)
          end
        end
      end
      raise ThreadError, 'queue empty' if @elems.empty?
      @elems.shift
    end
  end # def pop(blocking = true, timeout = nil)
end # class TimeoutQueue

__END__

timeout_queue = TimeoutQueue.new

# blocking pop, empty queue - new data is added after 5s
Thread.new { sleep 5; timeout_queue << 'foobar' }
timeout_queue.pop # => waits for 5s for data to arrive, then returns 'foobar'

# blocking pop, empty queue - no new data is added
timeout_queue.pop(true, 10) # => raises ThreadError after 10s


