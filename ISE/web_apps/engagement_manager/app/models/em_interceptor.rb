################################################################################
## Class:   EmInterceptor
## File:    em_interceptor.rb
## Author:  Daniel Jackson
## Company: Lockheed Martin, Missiles and Fire Control
## Desc:    This class represents an interceptor fired from a particular
##          launcher at a particular target.
##          It has convenience functions for finding common time values and
##          queries of current time categories.  It also has actions and queries
##          for its current status.  The status can be set directly through the
##          status action functions or automatically by updating the
##          interceptor.
class EmInterceptor

  ##############################################################################
  ##                            Attribute Methods                             ##
  ##############################################################################

  attr_reader :label
  attr_reader :launcher_label
  attr_reader :battery_label
  attr_reader :threat_label
  attr_reader :launch_time
  attr_reader :intercept_time
  attr_reader :status
  
  attr_reader :battery_rounds_available   # SMELL: This is silly
  attr_reader :launcher_rounds_available  # SMELL: This is silly

  ##
  # valid status values:
  #   :canceled   - intercept was cancelled before launch_time 
  #   :destroyed  - intercept was cancelled in flight_range
  #   :flying     - interceptor is currently in flight time
  #   :hit        - interceptor hit its target
  #   :missed     - interceptor missed its target
  #   :pending    - after intercept_time but still waiting for hit or miss result
  #   :waiting    - waiting for launch_time
  

  ##############################################################################
  ##                             General Methods                              ##
  ##############################################################################
  
  ####################
  def initialize(info)
    init_attributes
    
    set_interceptor_attributes(info)

    update_status
  end ## def initialize(attributes)
  
  
  ###########################################
  private # The following methods are private
  
  def instance_label
    return "#{@threat_label}::#{@launcher_label}::#{@label}"
  end
  
  ###################
  def init_attributes
    @label          = nil
    @launcher_label = nil
    @battery_label  = nil
    @threat_label   = nil
    @launch_time    = nil
    @intercept_time = nil
    @status         = nil
    @launcher_rounds_available  = 0
    @battery_rounds_available   = 0
  end ## def init_attributes
  
  
  ####################################
  def set_interceptor_attributes(info)
    return nil if info.nil?
    
    get_attributes_hash(info).each_pair do |attribute, value|
      if instance_variable_defined?(attribute)
        instance_variable_set(attribute, value)
      else
        raise("#{instance_label} - invalid interceptor attribute: #{attribute}.")
      end
    end
  end ## def set_interceptor_attributes(info)
  
  
  #############################
  def get_attributes_hash(info)
    attributes = Hash.new
        
    case info.class.to_s
    #########################
    when 'EmInterceptor' then
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
  
  #######################
  def update(info = nil)
    set_interceptor_attributes(info)
    
    update_status
  end ## def update(info = nil)
  


  #############################
  def update_launcher_inventory
    
    launcher(@launcher_label, :update_rounds_available, battery_rounds_available, launcher_rounds_available)
  
  end ## end of def update_launcher_inventory




  
  ########
  def to_s
    pretty_label = @label[0..1].upcase + ' ' + @label[2..@label.length - 1].humanize.upcase
    
    return pretty_label + case @status
    ##################
    when :waiting then
      ": Launch in #{ sprintf('%.1f', time_til_launch) } seconds."
    
    #################
    when :flying then
      ": Flying - Intercept of target in #{ sprintf('%.1f', time_til_intercept) } seconds."
      
    ##################
    when :pending then
      ": Determining the result of the engagement..."
      
    ####
    else
      ": #{@status}."   # was "The target was "
    end ## case @status
  end ## def to_s
  
  
  ##############################################################################
  ##                               Time Methods                               ##
  ##############################################################################

  ###############
  def flight_time
    return @intercept_time - @launch_time
  end ## def flight_time
  

  ################
  def flying_range
    return @launch_time..@intercept_time
  end ## def flying_range
  
  
  #########################
  def flight_time_remaining
    unless finished?
      before_launch? ? flight_time : time_til_intercept
    else
      return nil
    end
  end ## def flight_time_remaining  
  

  ###################
  def time_til_launch
    unless finished?
      ttl = @launch_time - $sim_time.now
  
      # Don't return negative time
      # This would happen if current time is after launch time
      return 0 > ttl ? 0 : ttl
    else
      return nil
    end
  end ## def time_til_launch
  

  ######################
  def time_til_intercept
    unless finished?
      tti = @intercept_time - $sim_time.now
  
      # Don't return negative time
      # This would happen if current time is after intercept time
      return 0 > tti ? 0 : tti
    else
      return nil
    end
  end ## def time_til_intercept

  
  ##################
  def before_launch?
    return $sim_time.now < @launch_time
  end ## def before_launch?
  

  #################
  def after_launch?
    return (not before_launch?)
  end ## def after_launch?
  

  #####################
  def before_intercept?
    return (not after_intercept?)
  end ## def before_intercept?
  

  ####################
  def after_intercept?
    return $sim_time.now > @intercept_time
  end ## def after_intercept?
  
  
  ###################
  def in_flight_time?
    return flying_range.include?($sim_time.now)
  end ## def in_flight_time?
  
  
  ##############################################################################
  ##                             Status Methods                               ##
  ##############################################################################
  
  ##############################     Actions     ###############################   

  ###########################################
  # private # The following methods are private
  
  #################
  def update_status
    if @launch_time.nil? or @intercept_time.nil?
      raise("#{instance_label} - no valid times, can't update status.")
    end
    
    case @status
    ##################
    when :waiting then
      launch if in_flight_time? # launch if it's time

    #################
    when :flying then
      wait_for_result if after_intercept? # wait for results of intercept
      
    #################
    when :canceled, :destroyed, :hit, :missed, :pending then
      # interceptor finished or waiting for result, do nothing
      
    ##################
    when nil then
      wait_for_launch

    ####
    else
      raise("#{instance_label} - unexpected status: #{@status}.")
    end ## case @status
  end ## def update_status
  
  
  ##########
  def cancel
    @status = :canceled
  end ## def cancel
    

  ###########
  def destroy
    @status = :destroyed
  end
  
  ##########################################
  # public # The previous methods were private
  

  #############
  # SMELL: Does not wait to react to sim message
  def disengage
=begin
    if waiting?
      return cancel
    elsif flying? or missed? or pending?
      return destroy
    end
=end
  end ## def disengage
  

  #######
  def hit
    @status = :hit
  end ## def hit
  

  ##########
  def launch
    @status = :flying
  end ## def launch
  

  ########
  def miss
    @status = :missed
  end ## def miss
    

  ########
  def wait_for_launch
    @status = :waiting
  end ## def wait
      

  ###################
  def wait_for_result
    @status = :pending
  end
  
  
  ##############################     Queries     ###############################
  
  ##########
  def alive?
    return (not finished?)
  end ## def alive?
  
  
  #############
  def canceled?
    return @status == :canceled
  end
  

  ##############
  def destroyed?
    return @status == :destroyed
  end
  

  #############
  def finished?
  
#    debug_me {:self}
  
    case @status
    ########################################################
    when :canceled, :destroyed, :hit, :missed then
    
#      debug_me
      return true

    ####
    else
#      debug_me
      return false
    end ## case @status
  end ## def finished?  
  

  ###########
  def flying?
    return @status == :flying
  end ## def flying?
  

  ########
  def hit?
    return @status == :hit
  end ## def hit?
  

  ###########
  def missed?
    return @status == :missed
  end ## def missed?
  

  ############
  def pending?
    return @status == :pending
  end ## def pending?

  alias_method :waiting_for_result?, :pending?
  

  ############
  def waiting?
    return @status == :waiting
  end ## def waiting?

  alias_method :waiting_for_launch?, :waiting?

end ## class EmInterceptor
