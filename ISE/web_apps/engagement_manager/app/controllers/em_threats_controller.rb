
# FIXME: Put this controller on a diet !!!

=begin
# methods defined in this controller are:
   index
   show
   get_current_threat
   self.get_current_threat
   get_current_threat_label
   self.get_current_threat_label
   
   get_threat(threat_label)
   set_current_threat
   update_threats
   order_disengagement
   order_engagement
   
   self.reset
   self.threat(threat_label, action = nil, *args)
   self.each_threat(action, threat_labels = nil, *args)
   self.add_threat(threat_info)
   self.engaged(interceptor_info)
   self.engage_failed(launcher_info)
   self.impacted(threat_label)
   self.launcher_bid_received(launcher_info)
   self.interceptor_hit(interceptor_info)
   self.interceptor_missed(interceptor_info)
   self.interceptor_terminated(interceptor_info)
   self.update_priority(threat_info)
=end

class EmThreatsController < ApplicationController
  
  ##############################################################################
  ##                               View Methods                               ##
  ##############################################################################
  
  #########
  # TODO: For debugging, remove this when stable
  def index
    begin
      update_threats
    rescue
      puts "update_threats failed: #{$!}"
    end
  end ## def index

  
  ########
  def show
    begin
      update_threats
    rescue
      puts "update_threats failed: #{$!}"
    end
  end ## def show
  
  
  ##############################################################################
  ##                              General Methods                             ##
  ##############################################################################
  
  ######################
  def get_current_threat
    return EmThreatsController.get_current_threat
  end ## def get_current_threat

  ###########################
  def self.get_current_threat
    return $em_threats[self.get_current_threat_label]
  end ## def self.get_current_threat
  
  
  
  ############################
  def get_current_threat_label
    return EmThreatsController.get_current_threat_label
  end ## def get_current_threat_label
  
  #################################
  def self.get_current_threat_label
    if $em_threats.include?($em_current_threat_label)
      return $em_current_threat_label
    else
      return ($em_current_threat_label = nil)
    end
  end ## def self.get_current_threat_label
  




  ############################
  def get_threat(threat_label)
    return $em_threats[threat_label]
  end ## def get_threat(threat_label)
  
  
  ######################
  # params = {'threat_label'}
  def set_current_threat
  
  
#    debug_me("WE ARE HERE"){:params}
  
  
    $em_current_threat_label = params['threat_label']
      
    EmTimeBarsController.set_current_duration
    
    EmMessagesController.prepare_to_engage_threat($em_current_threat_label)
  end ## def set_current_threat
  
  
  ##################
  def update_threats
    $em_threats.each_value do |threat|
      current_status = threat.status
      
      threat.update
      
      unless threat.status == current_status
        EmQueuesController.update_threat(threat.label)
      end
    end
  end ## def update_threats
  
  
  ##############################################################################
  ##                        Outgoing Message Methods                          ##
  ##############################################################################

  ################################################################
  # params = {'threat_label', 'launcher_label'}
  def order_disengagement
    begin
      threat_label = params['threat_label']
      launcher_label = params['launcher_label']
    
    
      EmMessagesController.disengage_threat(threat_label, launcher_label)
      
      $em_threats[threat_label].launcher_wait(launcher_label)
      
      head :ok
    rescue
      puts "em_threats_controller.order_disengagement failed: #{$!}"
      
      head :internal_server_error
    end
  end ## def order_disengagement(threat_label, launcher_label)
  
  
  #######################################################
  # params = {'threat_label', 'launcher_label'}
  def order_engagement
    begin
      threat_label = params['threat_label']
      launcher_label = params['launcher_label']
    
    
      EmMessagesController.engage_threat(threat_label, launcher_label)
    
      $em_threats[threat_label].launcher_wait(launcher_label)
      
      head :ok
    rescue
      puts "em_threats_controller.order_engagement failed: #{$!}"
          
      head :internal_server_error
    end
  end ## def order_engagement  
  
  
  ##############################################################################
  ##                          General Class Methods                           ##
  ##############################################################################
  
  ##############
  def self.reset
    $em_threats.clear # Hash of all threats for this run

    puts "All threats removed!" if $EM_DEBUG
  end ## def reset
  
  ###########################################
  private # The following methods are private
  
  #################################################
  def self.threat(threat_label, action = nil, *args)
  
    if threat_label.nil?
      debug_me(:tag=>"UNEXPECTED NIL", :trace => true){[:threat_label, :action, :args]}
    end
  
    if action.nil?
      return $em_threats[threat_label]
    else
      $em_threats[threat_label].method(action).call(*args)
    end
  end ## def self.threat(threat_label, action, *args)
  
  
  ###################################################
  def self.each_threat(action, threat_labels = nil, *args)
    unless action.nil?
      threat_labels = $em_threats.keys if threat_labels.nil?
      
      threat_labels = Array(threat_labels)
      
      threat_labels.each do |threat_label|
        threat(threat_label, action, *args)
      end
    else
      raise "threats[#{threat_labels.join(',')}] - action was nil."
    end
  end ## def self.each_threat(action, threat_label, *args)
  
  ##########################################
  public # The previous methods were private
  
  
  ##############################################################################
  ##                     Incoming Message Class Methods                       ##
  ##############################################################################
    
  ################################
  # threat_info = {'label', 'impact_time', 'defended_area', 'launch_area'}
  def self.add_threat(threat_info)
    label = threat_info['label']
    
#    debug_me "aaa"
        
    unless $em_threats.include?(label)
      $em_threats[label] = EmThreat.new(threat_info)
#    debug_me "bbb"
    else
      threat(label, :update, threat_info)
#    debug_me "ccc"
    end
    
    EmQueuesController.update_threat(label)
    
#     debug_me "ddd"
   
    
  end ## def self.detected(threat_info)
  
  
  ##################################
  # interceptor_info = {'label', 'launcher_label', 'threat_label',
  #                     'launch_time', 'intercept_time'}
  def self.engaged(interceptor_info)
  
#    debug_me
  
  
    label = interceptor_info['threat_label']
      
    threat(label, :engage, interceptor_info)
    
    #puts "**********  engaged  **********"  
    #pp interceptor_info
      
    EmQueuesController.update_threat(label)
  end ## def self.engaged(interceptor_info)
  
  
  #####################################
  # launcher_label = {'label', 'threat_label'}
  def self.engage_failed(launcher_info)
    label = launcher_info['threat_label']
      
    #puts "**********  engage_failed  **********"
    #pp interceptor_info
      
    threat(label, :deactivate_launcher, launcher_info['label'])

    EmQueuesController.update_threat(label)
  end ## def self.engage_failed(launcher_info)
  
  
  ###############################
  def self.impacted(threat_label)
    threat(threat_label, :impact)
    
    EmQueuesController.update_threat(threat_label)
  end ## def self.impacted(threat_label)
  

  #############################################
  # launcher_info = {'label', 'threat_label', 'bid', 'first_launch_time',
  #                  'first_intercept_time', 'last_launch_time',
  #                  'last_intercept_time', 'battery_label'}
  def self.launcher_bid_received(launcher_info)
    label = launcher_info['threat_label']
      
    threat(label, :launcher_bid, launcher_info)
  end ## def self.launcher_bid_received(launcher_info)

  
  ##########################################
  # interceptor_info = {'label', 'launcher_label', 'threat_label'}
  def self.interceptor_hit(interceptor_info)
    label = interceptor_info['threat_label']
      
    threat(label, :intercept, interceptor_info)
    
    EmQueuesController.update_threat(label)
  end ## def self.interceptor_hit(interceptor_info)

    
  #############################################
  # interceptor_info = {'label', 'launcher_label', 'threat_label'}
  def self.interceptor_missed(interceptor_info)
    label = interceptor_info['threat_label']
      
    threat(label, :interceptor_missed, interceptor_info)
    
    EmQueuesController.update_threat(label)
  end ## def self.interceptor_missed(interceptor_info)
    
    
  #################################################
  # interceptor_info = {'label', 'launcher_label', 'threat_label'}
  def self.interceptor_terminated(interceptor_info)
    label = interceptor_info['threat_label']

#    if interceptor_info['launcher_label'].nil?  
#      puts "**********  interceptor_terminated  **********"  
#      pp interceptor_info
#    end
          
    threat(label, :interceptor_terminated, interceptor_info)

    EmQueuesController.update_threat(label)
  end ## def self.interceptor_terminated(interceptor_info)
  
  
  #####################################
  def self.update_priority(threat_info)
    label = threat_info['label']
      
    threat(label, :update, threat_info)
    
    EmQueuesController.update_threat(label)
  end ## def self.update_priority(threat_label, threat_priority)

end ## class EmThreatsController < ApplicationController
