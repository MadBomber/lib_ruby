module BatteryFarmModel

  ###############################################
  ## A generic callback to dump incoming messages
  
  def self.threat_warning(a_header, a_message=nil)

    impact_time         = a_message.impact_time_
    radar_label         = a_message.radar_label_
    threat_label        = a_message.threat_label_
    defended_area_label = a_message.defended_area_label_
    launch_area_label   = a_message.launch_area_label_
    
    unless $active_threats.include?(threat_label)
      $active_threats[threat_label]  = Missile.new(threat_label)   if threat_label.is_red_missile?
      $active_threats[threat_label]  = Aircraft.new(threat_label)  if threat_label.is_red_aircraft?

      if (threat_label.is_aircraft? && $OPTIONS[:auto_engage_abt]) || (threat_label.is_missile? && $OPTIONS[:auto_engage_tbm])

        # only auto-engage missiles
        
        if TOC.can_engage?($active_threats[threat_label])
        
          result_array    = TOC.auto_engage($active_threats[threat_label])
          
          if result_array.nil?
            debug_me('SOMETHING HAPPENED BETWEEN CAN and DO'){:threat_label}
            return nil
          end
          
          selected_launcher_label = result_array[0]
          interceptors            = result_array[1]

          # publish every launcher's bid        
          TOC.bids[threat_label].each_pair do |launcher_label, launcher_bid_data|
            launcher_bid_message = LauncherBid.new
            launcher_bid_message.time_                  = $sim_time.now
            launcher_bid_message.launcher_label_        = launcher_label
            launcher_bid_message.threat_label_          = threat_label
            launcher_bid_message.bid_factor_            = launcher_bid_data.bid_factor
            launcher_bid_message.first_intercept_time_  = launcher_bid_data.first_intercept_time
            launcher_bid_message.last_intercept_time_   = launcher_bid_data.last_intercept_time
            launcher_bid_message.first_launch_time_     = launcher_bid_data.first_launch_time
            launcher_bid_message.last_launch_time_      = launcher_bid_data.last_launch_time
            
            launcher_bid_message.launcher_rounds_available_ = FARM[launcher_label].rounds_available
            launcher_bid_message.battery_rounds_available_  = BATTERY_FARM[FARM[launcher_label].battery_label].rounds_available
            
            launcher_bid_message.publish
          end
          
          
          if interceptors
            shooter = FARM[selected_launcher_label]
            
            te = ThreatEngaged.new
            te.time_            = $sim_time.now
            te.threat_label_    = threat_label
            te.launcher_label_  = selected_launcher_label

            te.launcher_rounds_available_ = shooter.rounds_available
            te.battery_rounds_available_  = BATTERY_FARM[shooter.battery_label].rounds_available
            
            interceptors.each do |interceptor_label|
            
              rock = shooter.rounds[interceptor_label]
              
              te.launch_time_       = rock.launch_time - $sim_time.start_time # convert to relative time
              te.impact_time_       = rock.impact_time - $sim_time.start_time # convert to relative time
              te.interceptor_label_ = rock.label
              te.publish
            end
            
          end
          
        end ## if TOC.can_engage?($active_threats[threat_label])
      
      end ## unless threat_label.is_aircraft?
      
    end ## end of unless $active_threats.include?(threat_label)

  end ## end of def self.threat_warning(a_header, a_message=nil)

end ## end of module BatteryFarmModel

