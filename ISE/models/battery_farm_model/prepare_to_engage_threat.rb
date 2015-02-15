module BatteryFarmModel

  ###############################################
  ## A generic callback to dump incoming messages
  
  def self.prepare_to_engage_threat(a_header, a_message=nil)
  
    debug_me('PREPARING'){[:a_header, :a_message]}  if $debug

    threat_label        = a_message.threat_label_
    
    debug_me('PREPARING'){:threat_label}  if $debug
    
    update_battery_farm   # gets the latest data for each battery

    unless $active_threats.include?(threat_label)
    
      debug_me("NOT ACTIVE"){:threat_label}     if $debug  
    
      $active_threats[threat_label]  = Missile.new(threat_label)   if threat_label.is_red_missile?
      $active_threats[threat_label]  = Aircraft.new(threat_label)  if threat_label.is_red_aircraft?

      if $active_threats.include? threat_label
        debug_me("NOW ITS ACTIVE"){"$active_threats[threat_label]"}  if $debug
      else
        debug_me("STILL NOT ACTIVE"){:threat_label}  if $debug
      end 

    end ## end of unless $active_threats.include?(threat_label)

        
        if TOC.can_engage?($active_threats[threat_label])
        
          result_array    = TOC.auto_engage($active_threats[threat_label], false) # collect the bids but do not launch

          if result_array.nil? || result_array.empty?
            debug_me("CAN _NOT_ ENGAGE"){[:threat_label]}
            tne = ThreatNotEngaged.new
            tne.time_           = $sim_time.now
            tne.threat_label_   = threat_label
            tne.launcher_label_ = ""
            tne.publish
            return nil
          else
            debug_me("CAN ENGAGE -- Bids Collected"){[:threat_label, :result_array, "TOC.bids[threat_label]"]}
          end
          
          
          selected_launcher_label = result_array[0]
          interceptors            = result_array[1]

          # publish every launcher's bid        
          TOC.bids[threat_label].each_pair do |launcher_label, launcher_bid_data|
          
          
            debug_me("LAUNCHER_BID") {[:launcher_label, :launcher_bid_data]}  if $debug
          
            launcher_bid_message                        = LauncherBid.new
            launcher_bid_message.time_                  = $sim_time.now
            launcher_bid_message.launcher_label_        = launcher_label
            launcher_bid_message.battery_label_         = FARM[launcher_label].battery_label
            launcher_bid_message.threat_label_          = threat_label
            launcher_bid_message.bid_factor_            = launcher_bid_data.bid_factor
            launcher_bid_message.first_intercept_time_  = launcher_bid_data.first_intercept_time
            launcher_bid_message.last_intercept_time_   = launcher_bid_data.last_intercept_time
            launcher_bid_message.first_launch_time_     = launcher_bid_data.first_launch_time
            launcher_bid_message.last_launch_time_      = launcher_bid_data.last_launch_time
            
            launcher_bid_message.launcher_rounds_available_  = FARM[launcher_label].rounds_available
            launcher_bid_message.battery_rounds_available_   = BATTERY_FARM[FARM[launcher_label].battery_label].rounds_available
            
            launcher_bid_message.publish

          debug_me("SENT LauncherBid"){[:threat_label, :launcher_label]}  if $debug
          
          end
                    
        else

          debug_me("CAN _NOT_ ENGAGE"){[:threat_label]}  if $debug
        
          tne = ThreatNotEngaged.new
          tne.time_           = $sim_time.now
          tne.threat_label_   = threat_label
          tne.launcher_label_ = ""
          tne.publish

        end ## if TOC.can_engage?($active_threats[threat_label])
      
      return nil

  end ## end of def self.prepare_to_engage_threat(a_header, a_message=nil)

end ## end of module BatteryFarmModel

