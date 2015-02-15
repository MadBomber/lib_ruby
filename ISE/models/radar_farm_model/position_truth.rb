##########################################################
###
##  File: position_truth.rb
##  Desc: Handle the PositionTruth message
#

module RadarFarmModel

  # Called when a position truth message comes in (see init.rb)
  # May publish a "threat_warning" or "threat_detected" message
  # "threat_warning" is after DETECTIONS_BEFORE_WARNING detects by 
  # a radar.

  def self.position_truth(a_header=nil, a_message=nil)
 
    # Short circuit when is a blue track
    return nil if a_message.label_.is_blue_force?

    # Label is used to determine the threat type
    threat_label  = a_message.label_
    threat_lla    = LlaCoordinate.new(a_message.position_)
    
    debug_me("POSITION-TRUTH"){[:threat_label, :threat_lla]} if $debug

    # Create a new entry if it does not exist
    # label naming convention is documented in aadse_utilities.rb
    # Note This is a factory. 
    unless $active_threats.include?(threat_label)
      debug_me("Never Seen This Threat Before") if $debug
      if threat_label[0,4].is_cruise_missile?
        $active_threats[threat_label] = CM.new(threat_label)
      elsif threat_label[0,2].is_missile?
        $active_threats[threat_label] = Missile.new(threat_label)
      else # otherwise its just some kind of generic aircraft; don't care about subtypes
        $active_threats[threat_label] = Aircraft.new(threat_label)
      end

      ## Insert effects_radius for this threat type into threat instance
      
      $active_threats[threat_label].effects_radius = $mpt[$active_threats[threat_label].type.downcase].effects_radius

      ## Emulate the radar sensitivy of this threat
      ## Use a uniform distribution of random draws of integers
      ## This threat must be deteched at least radar_detects_before_warning before a
      ## threat warning message is generated.  This technique spreads out warning events
      ## over time, reducing the impact of having many warnings at the same time.  The warning
      ## message causes dpwn stream evaluation of engagability by all launchers in the scenario.
      ## Having too many evaluations occure in the same sim frame causes the simulatino to slow down.
      $active_threats[threat_label].radar_detects_before_warning = rand(DETECTIONS_BEFORE_WARNING)
      
      debug_me('EMU-RDR-SEN'){[:threat_label, '$active_threats[threat_label].radar_detects_before_warning']}  if $debug

    end

    $active_threats[threat_label].lla = threat_lla

    # Loop over all radars in the farm for a detect/warning event
    FARM.each do |radar_label,radar|
    
      if radar.can_detect?($active_threats[threat_label])
      
        debug_me('DETECTED'){:threat_label} if $debug
        
        
        ## FIXME: This approach for issuing warnings based upon the number
        ##        of detection events is fine for TBM; HOWEVER, if
        ##        breaks down for air-breathers.  Consider a process
        ##        that takes the current position and determines if
        ##        it is inside a defended area or if within some XYZZY seconds
        ##        it will be with a defended area.  If the conditions are true
        ##        for now or the projected later time THEN issue the ThreatWarning.
        
        if $detected_threats[radar_label].include?(threat_label)
        
          $detected_threats[radar_label][threat_label] += 1

          debug_me('DETECTED-AGAIN'){[:threat_label, "$detected_threats[radar_label][threat_label]"]} if $debug

          if $active_threats[threat_label].radar_detects_before_warning < $detected_threats[radar_label][threat_label] # count maintained for each radar; not fused

            # MAGIC: 999_999_999 used to limit ThreatWarning to once per threat
            $active_threats[threat_label].radar_detects_before_warning = 999_999_999
            

            # Launch area label is used by engagement manager to calculate threat priority
            unless $active_threats[threat_label].launch_area_label
              $idp_launch_areas.each_pair do |shooter_label,v|
                launch_lla = $active_threats[threat_label].launch_lla
                launch_lla = $active_threats[threat_label].trajectory.first[0] if launch_lla.nil?
                $active_threats[threat_label].launch_area_label = shooter_label if launch_lla && v.area.includes?(launch_lla)
              end
            end
            
            # defended area label is used by engagement manager to calculate threat priority
            if $active_threats[threat_label].threat_to.empty?
              $idp_defended_areas.each_pair do |da_label,v|
                if v.area.includes?($active_threats[threat_label].impact_lla)
                  $active_threats[threat_label].threat_to << da_label 
                else
                  effects_radius  = $active_threats[threat_label].effects_radius
                  heading         = $active_threats[threat_label].impact_lla.heading_to(v.lla)
                  effects_point   = $active_threats[threat_label].impact_lla.endpoint( heading, effects_radius)
                  if v.area.includes?(effects_point)
                    $active_threats[threat_label].threat_to << da_label
                  end
                end
              end
            end

            # 'threat_to' is an array of unique defended area labels.
            unless $active_threats[threat_label].threat_to.empty?

              $threat_warning.time_                 = $sim_time.now
              $threat_warning.impact_time_          = $active_threats[threat_label].impact_time - $sim_time.start_time
              $threat_warning.threat_label_         = threat_label
              $threat_warning.threat_type_          = threat_label.split('_')[0][2,12].upcase  # type codified in label
              $threat_warning.radar_label_          = radar_label
              $threat_warning.launch_area_label_    = $active_threats[threat_label].launch_area_label

              $active_threats[threat_label].threat_to.flatten.uniq.each do |da_label|
                log_this("EVENT: #{radar_label} is warning #{da_label} about #{threat_label}")
                $threat_warning.defended_area_label_  = da_label
                $threat_warning.publish
              end ## end of $active_threats[threat_label].threat_to.flatten.uniq.each do |da_label|
              
            else
            
              log_this("EVENT: #{radar_label} has determined that #{threat_label} is NOT a threat to any defended area.")
              
            end ## end of unless $active_threats[threat_label].threat_to.empty?
          end ## end of if 5 == $detected_threats[threat_label]
        else  ## if $detected_threats.include?(threat_label)
          log_this("EVENT: #{radar_label} just detected #{threat_label}")
          $detected_threats[radar_label][threat_label] = 0
          $threat_detected.time_          = $sim_time.now
          $threat_detected.threat_label_  = threat_label
          $threat_detected.radar_label_   = radar_label
          $threat_detected.publish
        end ## if $detected_threats.include?(threat_label)

      end ## if radar.can_detect?($active_threats[threat_label])

    end ## FARM.each do |radar_label,r|
    

  end ## end of def self.position_truth(a_header=nil, a_message=nil)

end ## end of module RadarFarmModel





