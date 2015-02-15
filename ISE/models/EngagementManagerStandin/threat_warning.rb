module EngagementManagerStandin

  ###############################################
  ## A generic callback to dump incoming messages
  
  def self.threat_warning(a_header, a_message=nil)

    impact_time         = a_message.impact_time_
    threat_label        = a_message.threat_label_
    defended_area_label = a_message.defended_area_label_
    launch_area_label   = a_message.launch_area_label_
    
    unless $active_threats.include?(threat_label)
    
      $active_threats[threat_label]  = Missile.new(threat_label)   if threat_label.is_red_missile?
      $active_threats[threat_label]  = Aircraft.new(threat_label)  if threat_label.is_red_aircraft?      

      $active_threats[threat_label].impact_time         = impact_time
      $active_threats[threat_label].threat_to           = [ defended_area_label ]
      $active_threats[threat_label].launch_area_label   = [ launch_area_label ]

    else

      $active_threats[threat_label].threat_to         << defended_area_label  unless $active_threats[threat_label].threat_to.include?(defended_area_label)
      $active_threats[threat_label].launch_area_label << launch_area_label    unless $active_threats[threat_label].launch_area_label.include?(launch_area_label)

      # NOTE: area names follow a convention of NN_xxxxx... where NN is the value of the area
      #       arrange the areas in decending value order
      
      $active_threats[threat_label].threat_to.sort!.reverse!
      $active_threats[threat_label].launch_area_label.sort!.reverse!

    end ## end of unless $active_threats.include?(threat_label)

    threat_value = update_threat_priority( $active_threats[threat_label] )


    $threat_evaluation.time_                = $sim_time.now
    $threat_evaluation.threat_label_        = threat_label
    $threat_evaluation.threat_type_         = $active_threats[threat_label].type
    $threat_evaluation.defended_area_label_ = $active_threats[threat_label].threat_to[0]
    $threat_evaluation.launch_area_label_   = $active_threats[threat_label].launch_area_label[0]
    $threat_evaluation.impact_time_         = $active_threats[threat_label].impact_time
    $threat_evaluation.priority_            = threat_value
    $threat_evaluation.publish


  end ## end of def self.threat_warning(a_header, a_message=nil)

end ## end of module EngagementManagerStandin

