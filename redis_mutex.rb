# ;ob/ruby/redis_mutex.rb
# cross-process/cross-server mutex
# See:  http://blog.cloud66.com/ruby-mutex-mayhem/
#       but ... beware of the misspelling of synchronize
#
# $redis is a global variable that encapsulates a connection to your Redis instance.
#
# Usage Example:
=begin

  MY_MUTEX = RedisMutex.new('server_access', 10.seconds)
  # ...
  MY_MUTEX.synchronize(server.id) do
    # do some stuff here that needs to be synchronized
    # for this resource (across all application instances)
  end

=end


class RedisMutex

  attr_accessor :global_scope,
                :max_lock_time,
                :recheck_frequency

  # NOTE: This is a Lua script be run (eval'ed) on the Redis server
  LOCK_ACQUIRER = "return redis.call('setnx', KEYS[1], 1) == 1 and redis.call('expire', KEYS[1], KEYS[2]) and 1 or 0"


  def initialize(global_scope, max_lock_time, recheck_frequency: 1)

    # the global scope of this mutex (i.e "resource")
    @global_scope = global_scope

    # max time in seconds to hold the mutex
    # (in case of greedy deadlock)
    @max_lock_time = max_lock_time

    # recheck frequency how often to check if the mutex is
    # released when blocked
    @recheck_frequency = recheck_frequency

  end


  def synchronize(local_scope = :global, &block)

    # get the lock
    acquire(local_scope)

    begin
      # execute the actions
      return block.call
    ensure
      # release the lock
      release(local_scope)
    end

  end


  ##################################################################
  private


  # attempt to acquire the lock
  def acquire(local_scope = :global)

    # construct the mutex key; the local scope
    # of this mutex (i.e "resource_id")
    mutex_key = "#{@global_scope}.#{local_scope}"


    # while statement will either get the lock and
    # set the expiry on the lock or do neither and return 0
    while $redis.eval(LOCK_ACQUIRER, [mutex_key, @max_lock_time]) != 1 do

      # wait and try again (until we can get in)
      sleep(@recheck_frequency)

    end

  end


  # release the lock
  def release(local_scope = :global)
    # return value indicating whether the lock was currently held
    mutex_key = "#{@global_scope}.#{local_scope}"
    return $redis.del(mutex_key) == 1
  end

end  # class RedisMutex
