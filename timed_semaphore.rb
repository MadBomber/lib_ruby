##########################################################
###
##  File: timed_semaphore.rb
##  Desc: see https://crondev.com/ruby-timedsemaphore
#

# depends on the concurrent-ruby gem
require 'concurrent'
 
class TimedSemaphore
  def initialize(num_of_ops, num_of_seconds)
    @count = 0
    @limit = num_of_ops
    @period = num_of_seconds
    @lock = Monitor.new
    @condition = @lock.new_cond
    @timer_task = nil
  end
 
  def acquire
    @lock.synchronize do
      # Sleep thread if all available permits are exhausted
      @condition.wait while @limit > 0 && @count == @limit
      @count += 1
      # Start the timer for releasing all acquired permits
      start_timer if @timer_task.nil?
    end
  end
 
  private
 
  def start_timer
    @lock.synchronize do
      @timer_task = Concurrent::ScheduledTask.execute(@period) { end_of_period }
    end
  end
 
  def end_of_period
    @lock.synchronize do
      @timer_task = nil
      @count = 0
      # Wakes up all sleeping threads waiting for this condition
      @condition.broadcast
    end
  end
end
