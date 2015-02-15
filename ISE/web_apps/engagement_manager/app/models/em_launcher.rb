################################################################################
## Class:   EmLauncher
## File:    em_launcher.rb
## Author:  Daniel Jackson
## Company: Lockheed Martin, Missiles and Fire Control
## Desc:    This class represents a launcher that is targeting a particular
##          threat.  It is *not* a launcher object, but a particular engagement
##          associated with a bid against that threat.  If or when it engages a
##          threat, it will have interceptors associated with itself and that
##          threat.
##          It has convenience functions for finding common time values and
##          queries of current time categories.  It also has actions and queries
##          for its current status.  The status can be set directly through the
##          status action functions or automatically by updating the launcher.

# FIXME: do not embedded the interceptor objects, keep them in the global
#        $em_interceptors data store; in this class just keep the interceptors' label
#        in the hash/array as a key into the global data store
require 'em_interceptor'

class EmLauncher

  ##############################################################################
  ##                            Attribute Methods                             ##
  ##############################################################################

  attr_reader :label
  attr_reader :type
  attr_reader :unit_id

  attr_reader :threat_label
  attr_reader :battery_label
  attr_reader :bid
  attr_reader :first_launch_time
  attr_reader :first_intercept_time
  attr_reader :last_launch_time
  attr_reader :last_intercept_time
  attr_reader :interceptors
  attr_reader :status
  
  attr_reader :launcher_rounds_available
  attr_reader :battery_rounds_available
  
  ##
  # valid status values:
  #   :active   - is available for engagement of the threat 
  #   :engaging - is currently engaging the threat
  #   :inactive - is no longer available for engagement of the threat
  #   :hit      - intercepted a threat
  #   :pending  - has ordered an engagement or cancel engagement against a
  #               threat, but has yet to receive confirmation of order execution

  ##############################################################################
  ##                             General Methods                              ##
  ##############################################################################
  
  ##########################
  def initialize(info)
    init_attributes
    
    set_launcher_attributes(info)
    
    update_status
  end ## def initialize(attributes)
  
  
  ###########################################
  private # The following methods are private
  
  def instance_label
    return "#{@threat_label}::#{@label}"    
  end
  
  ###################
  def init_attributes
    @label                = nil
    @type                 = nil
    @unit_id              = nil
    @threat_label         = nil
    @battery_label        = nil
    @bid                  = nil
    @first_launch_time    = nil
    @first_intercept_time = nil
    @last_launch_time     = nil
    @last_intercept_time  = nil
    @status               = nil
    @interceptors         = Hash.new
    @launcher_rounds_available  = 0
    @battery_rounds_available   = 0
  end ## def init_attributes
  
  
  #################################
  def set_launcher_attributes(info)
    return nil if info.nil?
    
    get_attributes_hash(info).each_pair do |attribute, value|
      if instance_variable_defined?(attribute)
        instance_variable_set(attribute, value)
      else
        raise("#{instance_label} - invalid launcher attribute: #{attribute}.")
      end
    end ## get_attributes_hash(info).each_pair do |attribute, value|
    
    a = @label.split '_'
    @unit_id = a[1]
    @type    = a[0][2,98]
    
  end ## def set_interceptor_attributes(info)
  
  
  #############################
  def get_attributes_hash(info)
    attributes = Hash.new
        
    case info.class.to_s
    #########################
    when 'EmLauncher' then
      info.instance_variables.each do |variable_name|
        attributes[variable_name] = info.instance_variable_get(variable_name)
      end
      
    ################
    when 'Hash' then
      info.each_pair do |attribute, value|
        unless attribute[0] == '@'
          attributes["@#{attribute}"] = value
        else
          return info
        end
      end
      
    ####
    else
      raise("#{instance_label} - unexpected attribute parameter type: #{info.class}")
    end
    
    return attributes
  end ## def get_attributes_hash(info)
  
  
  ##########################################
  public # The previous methods were private
  
  ######################
  def update(info = nil)
    set_launcher_attributes(info)

    each_interceptor(:update)
    
    update_status
  end ## def update(info)
  

  ###########################################################
  def update_rounds_available(battery_qty=0, launcher_qty=0)
  
    @battery_rounds_available   = battery_qty
    @launcher_rounds_available  = launcher_qty
  
  end ## end of def update_rounds_available(battery_qty, launcher_qty)


  
  ##############################################################################
  ##                               Time Methods                               ##
  ##############################################################################

  #####################
  def first_flight_time
    return @first_intercept_time - @first_launch_time
  end ## def first_flight_time
  

  ####################
  def last_flight_time
    return @last_intercept_time - @last_launch_time
  end ## def last_flight_time
  
  
  #############
  def time_left
    unless finished?
      tl = @last_launch_time - $sim_time.now
  
      # Don't return negative time
      # This would happen if current time is after last launch time
      return 0 > tl ? 0 : tl
    else
      return nil
    end
  end ## def time_left
  
  
  ##############
  def can_shoot?
    alive = $em_threats[@threat_label].alive?
    tl = time_left
    
    return (not tl.nil? and (alive and tl > 0)) 
  end ## def can_shoot?
    
  
  ##############################################################################
  ##                             Status Methods                               ##
  ##############################################################################
  
  ##############################     Actions     ###############################
  
  ###########################################
  private # The following methods are private
  
  #################
  def update_status
    
    case @status
    #################
    when :active then
      deactivate unless can_shoot?
      
    ###################
    when :engaging then
      if all_interceptors_finished?
#        debug_me
        reset_status 
      end
    
    ###################################
    when :inactive, :hit, :pending then
      # launcher is finished or waiting for response, do nothing
      
    #############
    when nil then
      init_status
      
    ####
    else
      raise("#{@label} had an unexpected status: #{@status}.")
    end ## case @status
    
  end ## def update_status
    
  
  ###############
  def init_status
    if can_shoot?
      activate
    else
      deactivate
    end
  end ## def init_status
  
  alias_method :reset_status, :init_status
  
  
  ############
  def activate
  
#    debug_me(:tag =>"WHO SAZ", :trace => true)
  
    @status = :active
  end ## def activate
  
  alias_method :reactivate, :activate
  
  ##############
  def deactivate
    @status = :inactive if all_interceptors_finished?
  end ## def deactivate
  
  ##########################################
  public # The previous methods were private
  
  
  #######################################
  def disengage(interceptor_labels = nil)
    each_interceptor(:disengage, interceptor_labels)
    
    reset_status 
  end ## def disengage
  
  
  ############################
  def engage(interceptor_info)
  
  
    interceptor = EmInterceptor.new(interceptor_info)
            
    @interceptors[interceptor.label] = interceptor

    @status = :engaging
    
#    debug_me {[:label, :status]}
  

  end ## def engage(interceptor_info)
  
  
  #################
  def engage_failed
    reset_status
  end ## def engage_failed
  
  
  ##########################
  def hit(interceptor_info)
    interceptor(interceptor_info['label'], :hit)
    
    @status = :hit
  end ## def hit(interceptor_label)
  
  
  ###########################
  def miss(interceptor_info)
    interceptor(interceptor_info['label'], :miss)
    
    reset_status if all_interceptors_finished?
  end ## def miss(interceptor_label)
  
  
  #####################
  def wait_for_response
    @status = :pending
  end ## def wait_for_response
  
  
  ##############################     Queries     ###############################

  ###########
  def active?
    return @status == :active
  end ## def active?
  
  
  ##########
  def alive?
    return (not finished?)
  end ## def alive?

  
  #############
  def engaging?
    @status == :engaging
  end ## def engaging?
  
  
  #############
  def finished?
    case @status
    ####################
    when :inactive, :hit
      return true
      
    ####
    else
      return false
    end ## case @status
  end ## def finished?
  
  
  ########
  def hit?
    @status == :hit
  end
  

  #############
  def inactive?
    @status == :inactive
  end ## def inactive?
  
  
  ############
  def pending?
    @status == :pending
  end
  
  alias_method :waiting_for_response?, :pending?
  
  
  ##############################################################################
  ##                          Interceptor Methods                             ##
  ##############################################################################
  
  ##############################
  def all_interceptors_finished?
  
    my_answer = true
    
#    debug_me("ALL_ROCKS_FINISHED? INIT") {:my_answer}
    
    @interceptors.each_value do |interceptor|
      rock_done = interceptor.finished?
      
      puts "#{my_answer} and #{rock_done}"
#      debug_me("ALL_ROCKS_FINISHED?") {[:my_answer, :rock_done, :interceptor]}
            
      my_answer = (my_answer and rock_done)

#      puts "is #{my_answer}"
#      debug_me("ALL_ROCKS_FINISHED?") {[:my_answer]}


    end
    
    
#    debug_me("ALL_ROCKS_FINISHED? RETURNING") {:my_answer}
    
    return my_answer
    
  end ## def all_interceptors_finished?
  
  ###########################################
  private # The following methods are private
  
  ########################################################
  def interceptor(interceptor_label, action = nil, *args)
    if action.nil?
      return @interceptors[interceptor_label] # just return the interceptor
    else
      @interceptors[interceptor_label].method(action).call(*args)
    end
  end ## def threat_action(threat_label, action, *args)
  
  
  #########################################################
  def each_interceptor(action, interceptor_labels = nil, *args)
    interceptor_labels = @interceptors.keys if interceptor_labels.nil?
          
    interceptor_labels = Array(interceptor_labels)
    
    unless action.nil?    
      interceptor_labels.each do |interceptor_label|
        interceptor(interceptor_label, action, *args)
      end
    else
      raise "#{instance_label}.interceptors[#{interceptor_labels.join(',')}] - action was nil."
    end
  end ## def interceptors(action, interceptor_labels, *args)

end ## class EmLauncher
