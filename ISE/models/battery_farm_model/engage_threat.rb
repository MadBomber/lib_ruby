module BatteryFarmModel

  ###############################################
  ## Process EngageThreat messages
  
  def self.engage_threat(a_header, a_message=nil)

    threat_label    = a_message.threat_label_
    launcher_label  = a_message.launcher_label_
    
    debug_me{["a_header.frame_count_", :threat_label, :launcher_label]}
    
    return(nil) unless FARM.include?(launcher_label)
    
    unless $active_threats.include?(threat_label)
      $active_threats[threat_label]  = Missile.new(threat_label)   if threat_label.is_red_missile?
      $active_threats[threat_label]  = Aircraft.new(threat_label)  if threat_label.is_red_aircraft?
      # TODO: What happens if the threat was not a red missile or aircraft?
    end ## end of unless $active_threats.include?(threat_label)
    
    shooter       = FARM[launcher_label]
    interceptors  = shooter.engage $active_threats[threat_label]
    
    if interceptors.nil?
    
      tne = ThreatNotEngaged.new
      tne.time_           = $sim_time.now
      tne.threat_label_   = threat_label
      tne.launcher_label_ = launcher_label
      tne.publish
      
    else
      
      te                  = ThreatEngaged.new
      te.time_            = $sim_time.now
      te.threat_label_    = threat_label
      te.launcher_label_  = launcher_label
      te.battery_label_   = shooter.battery_label
            
      te.launcher_rounds_available_  = shooter.rounds_available
      te.battery_rounds_available_   = 4269      # TODO: sum the rounds_available for all launchers in this battery
      
      interceptors.each do |interceptor_label|
      
        rock = shooter.rounds[interceptor_label]
        
        te.launch_time_       = rock.launch_time - $sim_time.start_time
        te.impact_time_       = rock.impact_time - $sim_time.start_time
        te.interceptor_label_ = rock.label
        te.publish
        
#        debug_me("ThreatEngagedMessage") {["$sim_time.now","te.threat_label_","te.launcher_label_","te.time_","te.launch_time_","te.impact_time_"]}
      
      end
      
    end

  end ## end of def self.engage_threat(a_header, a_message=nil)

end ## end of module BatteryFarmModel

