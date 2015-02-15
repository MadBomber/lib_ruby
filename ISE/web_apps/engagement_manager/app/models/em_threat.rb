################################################################################
## Class:   EmThreat
## File:    em_threat.rb
## Author:  Daniel Jackson
## Company: Lockheed Martin, Missiles and Fire Control
## Desc:    This class represents a threat that has been detected.  It will have
##          associated launchers and interceptors as it receives messages of
##          launcher bids and engagements.
##          It has convenience functions for finding common time values and
##          queries of current time categories.  It also has actions and queries
##          for its current status.  The status can be set directly through the
##          status action functions or automatically by updating the threat.

# FIXME: Do not embedded the launcher object into the threat object; rather just
#        keep track of the launcher_label for use as a key into the global data store
#        BUT you can't do that because the launcher object contains threat specific time data
require 'em_launcher'

class EmThreat
  ##############################################################################
  ##                            Attribute Methods                             ##
  ##############################################################################
  
  ENGAGEMENT_PROTOCOL_STATES  = { :waiting        => "Waiting for Launcher Bids",
                                  :bid_received   => "Launcher Bids Received",
                                  :cannot_engage  => "Threat Cannot be Engaged"
                                }
  
  attr_reader :label
  attr_reader :impact_time
  attr_reader :priority
  attr_reader :defended_area
  attr_reader :launch_area
  attr_reader :launchers

  # valid status values coorespond to $valid_queue_names:
  #   :engaged     - is currently scheduled for engagement by a launcher 
  #   :intercepted - has been destroyed by an interceptor 
  #   :leaked      - hit its intended defended area
  #   :unengaged   - has yet to be scheduled for engagement by any launchers
  attr_reader :status
  
  # A text description of where we are in the engagement_protocol.
  # Used for operator feedback.
  attr_accessor :engagement_protocol_progress
  

  ##############################################################################
  ##                             General Methods                              ##
  ##############################################################################
  
  ##########################
  def initialize(info)
    init_attributes
    
    set_threat_attributes(info)
    
    update_status
  end ## def initialize(attributes)
  
  
  ###########################################
  #private # The following methods are private
  
  ###################
  def init_attributes
    @label         = nil
    @impact_time   = nil
    @priority      = 0.0
    @defended_area = nil
    @launch_area   = nil
    @launchers     = Hash.new
    @status        = nil
    
    @engagement_protocol_progress  = EmThreat::ENGAGEMENT_PROTOCOL_STATES[:waiting]
    
  end ## def init_attributes
  
  
  #################################
  def set_threat_attributes(info)
    return nil if info.nil?
    
    get_attributes_hash(info).each_pair do |attribute, value|
  
  # debug_me(:tag=>'DEBUG', :file=>$stderr){[:attribute, :value]}
  
      if instance_variable_defined?(attribute)
        case attribute
          when '@defended_area' then
            if @defended_area
  # debug_me(:tag=>'DEBUG defended_area is __NOT__ nil', :file=>$stderr){}
              @defended_area << value
              @defended_area.sort!.reverse!
            else
  # debug_me(:tag=>'DEBUG defended_area is nil', :file=>$stderr)
              @defended_area = [value]
            end
          when '@launch_area' then
            if @launch_area
              @launch_area << value
              @launch_area.sort!.reverse!
            else
              @launch_area = [value]
            end
          else
            instance_variable_set(attribute, value)
        end
      else
        raise("#{@label} - invalid threat attribute: #{attribute}.")
      end
    end ## get_attributes_hash(info).each_pair do |attribute, value|
  end ## def set_interceptor_attributes(info)
  
  
  #############################
  def get_attributes_hash(info)
    attributes = Hash.new
        
    case info.class.to_s
    #########################
    when 'EmThreat' then
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
      raise("#{@label} - unexpected attribute parameter type: #{info.class}")
    end
    
    return attributes
  end ## def get_attributes_hash(info)
  


  
  ##########################
  def get_engaging_launchers
  
    engaging_launchers = Array.new
    
    @launchers.each_value do |shooter|
      engaging_launchers << shooter if :engaging == shooter.status
    end
    
    return engaging_launchers
  
  end
  
  ########################
  def get_active_launchers
  
    active_launchers = Array.new
    
    @launchers.each_value do |shooter|
      active_launchers << shooter if :active == shooter.status
    end
    
    return active_launchers

  end



  ##########################################
  #public # The previous methods were private
  
  ######################
  def update(info = nil)
    set_threat_attributes(info)

    each_launcher(:update)
        
    update_status
  end ## def update(info)
  


  ###################
  def time_til_impact
    unless intercepted?
      tti = @impact_time - $sim_time.now
      # Don't return negative time
      # This would happen if current time is after impact time
      return 0 > tti ? 0 : tti
    else
      return nil
    end
  end ## def time_til_impact
    
  
  ##############################################################################
  ##                             Status Methods                               ##
  ##############################################################################
  
  ##############################     Actions     ###############################
  
  ###########################################
  private # The following methods are private
  
  #################
  def update_status
  
  
#  debug_me("ENTERING"){}
  
  
    case @status
    ##################
    when :engaged then
      if should_disengage?
      
#      debug_me
      
        disengage
      end
      
#      debug_me
      
    ###########################################
    when :intercepted, :leaked, :unengaged then
      # threat is finished or isn't engaged yet, do nothing
    
#      debug_me
    
    #############
    when nil then
      init_status
      
#      debug_me
      
    ####
    else
      raise("#{@label} - unexpected status: #{@status}.")
    end
    
#    debug_me("LEAVING")
    
  end ## def update_status
  
  
  ###############
  def init_status
  
#  debug_me{:@status}
  
    if a_launcher(:engaging?)   # SMELL
      @status = :engaged
    else
      @status = :unengaged
    end

#  debug_me{:@status}

  end ## def init_status
  
  
  #####################
  def should_disengage?
    
    condition_one = no_launchers(:engaging?)
    condition_two = no_launchers(:pending?)
    
#    debug_me {[:condition_one, :condition_two]}
    
  
    return (condition_one and condition_two)
    
  end ## def should_disengage?
  
  ##########################################
  public # The previous methods were private
  
  
  ####################################
  def disengage(launcher_labels = nil)
    each_launcher(:disengage, launcher_labels)
    
    @status = :unengaged if should_disengage?
  end ## def disengage(launcher_label)
  
  
  ##############################################
  def deactivate_launcher(launcher_labels = nil)
    each_launcher(:deactivate, launcher_labels)
  end
  
  
  ############################
  def engage(interceptor_info)
  
#    debug_me
  
    launcher_label = interceptor_info['launcher_label']
      
    launcher(launcher_label, :engage, interceptor_info)
    
    @status = :engaged
    
#    debug_me {:self}
    
  end ## def engage(interceptor_info)
  

  ##########
  def impact
    @status = :leaked
    
    each_launcher(:disengage)
  end ## def impact
  
  alias_method :leak, :impact
  

  ###############################
  def intercept(interceptor_info)
    launcher_label = interceptor_info['launcher_label']
      
    launcher(launcher_label, :hit, interceptor_info)
    
    @status = :intercepted
    
    # SMELL: This fortells the reaction of the sim instead of reacting to sim messages
    # other_launchers(:disengage, launcher_label)
  end ## def intercept(interceptor_info)  
  
  
  ##############################     Queries     ###############################
  
  ##########
  def alive?
    return (not finished?)
  end ## def alive?
  
  
  ############
  def engaged?
    return @status == :engaged
  end ## def engaged?
  
  
  #############
  def finished?
    case @status
    #################################
    when :intercepted, :impacted then
      return true
      
    ####
    else
      return false
    end
  end ## def finished?
  
  
  #############
  def impacted?
    return @status == :leaked
  end ## def impacted?
  
  alias_method :leaked?, :impacted?
  
  
  ################
  def intercepted?
    return @status == :intercepted
  end ## def intercepted?
  
  
  ##############
  def unengaged?
    @status == :unengaged
  end ## def unengaged?
  
  
  ##############################################################################
  ##                            Launcher Methods                              ##
  ##############################################################################
  
  ######################
  def a_launcher(status)
    return (not no_launchers(status))
  end ## def a_launcher(status)
  
  
  ########################
  def no_launchers(status)
  
#    debug_me("ENTERING"){:status}
  
    @launchers.each_value do |launcher|
#      debug_me{[:launcher,"launcher.method(status).call"]}
      return false if launcher.method(status).call  # find first (if any) exception
    end
    
#    debug_me("LEAVING")
    
    return true
  end ## def no_launchers(status)
  
  
  ###############################
  def launcher_bid(launcher_info)
    launcher_label = launcher_info['label']
      
    if @launchers.include?(launcher_label)
      launcher(launcher_label, :update, launcher_info)
    else
      @launchers[launcher_label] = EmLauncher.new(launcher_info)
    end
  end ## def launcher_bid(launcher_info)
  
  
  #################################
  def launcher_wait(launcher_label)
    launcher(launcher_label, :wait_for_response)
  end ## def launcher_wait(launcher_label)
  
  
  ########################################
  def interceptor_missed(interceptor_info)
    launcher_label = interceptor_info['launcher_label']
      
    launcher(launcher_label, :miss, interceptor_info) 
  end ## def interceptor_missed(launcher_label, interceptor_label)
  
  
  ############################################
  def interceptor_terminated(interceptor_info)
  
#    debug_me("ROCK_TERMINATED"){:interceptor_info}
    
    self_destruct     = interceptor_info['self_destruct']
    interceptor_label = interceptor_info['label']
    launcher_label    = interceptor_info['launcher_label']

    launcher(launcher_label, :disengage, interceptor_info['label'])
    
    if "1" == self_destruct
      @launchers[launcher_label].interceptors[interceptor_label].destroy
    else
      @launchers[launcher_label].interceptors[interceptor_label].cancel
    end
    
  end
  
  
  ###########################################
  private # The following methods are private
  
  #################################################
  def launcher(launcher_label, action = nil, *args)
    if action.nil?
      return @launchers[launcher_label] # just return the launcher
    else
      @launchers[launcher_label].method(action).call(*args)
    end
  end ## def launcher(launcher_label, action, *args)
  
  
  #######################################################
  def each_launcher(action, launcher_labels = nil, *args)
    unless action.nil?
      result = true
      
      launcher_labels = @launchers.keys if launcher_labels.nil?
      
      launcher_labels = Array(launcher_labels)
      
      #pp launcher_labels
      
      launcher_labels.each do |launcher_label|
        launcher(launcher_label, action, *args)
      end
    else
      raise "#{label}.launchers[#{launcher_labels.join(',')}] - action was nil."
    end
  end ## def each_launcher(action, launcher_labels, *args)
  
  
  ###################################################
  def other_launchers(action, launcher_labels, *args)
    other_launcher_labels = @launchers.keys - Array(launcher_labels)
    
    each_launcher(action, other_launcher_labels, *args)
  end ## def other_launchers(action, launcher_labels, *args)
  
end ## class EmThreat
