module ThreatFarmModel

  def self.start_frame(a_header=nil, a_message=nil)
    
    debug_me{"a_header.frame_count_"}  if $debug
    
    $sim_time.advance_time
    
    # NOTE: This model is message reqactive.  This means that start_frame
    #       is only used to advance the sim-wide time.  Current IseProtocol
    #       requires that an end_frame be sent back before any new start_frames
    #       can be sent.
    
    FARM.each_pair do |threat_label, threat|
      log_event "Launch #{threat_label}" if $sim_time.sim_time == threat.launch_time

      if threat.life_span.include? $sim_time.sim_time

        lla       = threat.current_position
        velocity  = threat.current_velocity
        attitude  = threat.current_attitude
        
        unless lla.nil?
          $position_truth.time_     = $sim_time.now
          $position_truth.label_    = threat_label
          $position_truth.position_ = lla.to_a
          $position_truth.velocity_ = velocity
          $position_truth.attitude_ = attitude
          $position_truth.publish
        end
                
      end
            
      if $sim_time.sim_time >= threat.impact_time
        log_event "Impact #{threat_label}"
        FARM.delete(threat_label)
        log_this "Threats left: #{ThreatFarmModel::FARM.length}"
        $threat_impacted.time_          = $sim_time.now
        $threat_impacted.threat_label_  = threat_label
        $threat_impacted.publish
      end
      
    end ## end of FARM.each_pair do |threat_label, threat|
    
    if $OPTIONS[:real_time]
      # slow down fast sims to approximate near-realtime performance
      # to support man-in-the-loop

      sleep_time  = 1.0 - (Time.now - $last_realtime) # MAGIC: 1.0 real-time seconds per frame   
      sleep(sleep_time)  if sleep_time > 0.0
      
      $last_realtime = Time.now

    end
    
    $end_frame = EndFrame.new unless defined?($end_frame)
    $end_frame.publish
    
  end

end
