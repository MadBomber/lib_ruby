####################################################################
###
##  File: SimEvent.rb
##  Desc: Generic events that can be record to cache during the running of a sim
#

class SimEvent

  @@PREFIX = 'Event:'

  attr_accessor :sim_time       # current $sim_time.sim_time
  attr_accessor :object_name    # name of the object that is reporting the event
  attr_accessor :event_name     # event name (category-like) cooresponds to the instance name an cache keys
  attr_accessor :event_desc     # free text that further clarifies the event_name
  attr_accessor :manager_pop    # last_popped_event integer
  attr_accessor :manager_push   # last_pushed_event integer
  attr_accessor :long_description   # a longer description what the event_name really means
  attr_accessor :base_key
  
  ##########################
  def initialize(event_name, long_description="")
    @event_name       = event_name  # acts like a category
    @event_desc       = nil
    @sim_time         = nil
    @object_name      = nil
    @long_description = long_description
    @base_key     = "#{@@PREFIX}#{@event_name}"
    @pop_key      = "#{base_key}_pop"
    @push_key     = "#{@@PREFIX}#{@event_name}_push"
    
    SharedMemCache.add(@base_key, @long_description)    
    SharedMemCache.add(@pop_key,  "Stack management for event #{event_name}")
    SharedMemCache.add(@push_key, "Stack management for event #{event_name}")

    SharedMemCache.set(@pop_key,  0) unless SharedMemCache.get(@pop_key)
    SharedMemCache.set(@push_key, 0) unless SharedMemCache.get(@push_key)

  end
  
  #####################
  def push(object_name, event_desc="")
  
    @object_name  = object_name
    @event_desc   = event_desc
    @sim_time     = $sim_time.sim_time
  
    next_event_to_push = SharedMemCache.get(@push_key) + 1
    
    h = { 'sim_time'    => @sim_time, 
          'event_name'  => @event_name, 
          'event_desc'  => @event_desc, 
          'object_name' => @object_name}
          
    SharedMemCache.set("#{@@PREFIX}#{@event_name}_#{next_event_to_push}", h)
    SharedMemCache.set(@push_key, next_event_to_push)

    log_this "SimEvent: #{@event_name} has been pushed: #{h.pretty_inspect}"
        
    return h
  end
  
  #######
  def pop

    last_event_pushed = SharedMemCache.get(@push_key)
    next_event_to_pop = SharedMemCache.get(@pop_key) + 1
    
    return nil if next_event_to_pop > last_event_pushed
    
    key = "#{@@PREFIX}#{@event_name}_#{next_event_to_pop}"
    h = SharedMemCache.get(key)
    SharedMemCache.delete(key)
    SharedMemCache.set(@pop_key, next_event_to_pop)

    log_this "SimEvent: #{@event_name} has been poped: #{h.pretty_inspect}"
    
    return h
  end
  
  #########
  def reset
  
    log_this "SimEvent: #{@event_name} has been reset"

    last_event_pushed = SharedMemCache.get(@push_key)
    next_event_to_pop = SharedMemCache.get(@pop_key) + 1

    SharedMemCache.set(@pop_key,  0)
    SharedMemCache.set(@push_key, 0)
    
    return nil if next_event_to_pop > last_event_pushed
    
    (next_event_to_pop .. last_event_pushed).step do |x|
      key = "#{@@PREFIX}#{@event_name}_#{x}"
      SharedMemCache.delete(key)
    end

    return nil
    
  end
  
  ###########################
  alias :declare_event  :push
  alias :record_event   :push
  alias :save_event     :push
  alias :store_event    :push
  alias :set_event      :push
  #
  alias :get_event      :pop
  alias :retrieve_event :pop
  alias :next_event     :pop

end ## end of class SimEvent


###########################################################
## Define events to log

$engagement_failure       = SimEvent.new('engagement_failure',      'An engagement failed')
$engagement_cancelled     = SimEvent.new('engagement_cancelled',    'User cancelled an engagement')
$interceptor_terminated   = SimEvent.new('interceptor_terminated',  'User caused self-destruct of interceptor')



