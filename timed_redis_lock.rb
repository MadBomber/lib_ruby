# ~/lib/ruby/timed_redis_lock.rb

# require 'redis'

class TimedRedisLock
  def initialize(name:'lock', redis: Redis.new)
    @lock_name  = name
    @redis      = redis
  end

  def lock!(ttl_seconds=3)
    @redis.set(@lock_name, Time.now.to_f, ex: ttl_seconds)
  end
  alias_method :extend!, :lock!

  # returns true until the named not no longer exists
  #
  def locked?
    1 == @redis.exists(@lock_name)
  end
end

__END__

Usage:

r = TImedRedisLock.new
r.lock!(3) # seconds

do_this unless r.locked? 

while r.locked? do 
  puts Time.now.to_f 
end




