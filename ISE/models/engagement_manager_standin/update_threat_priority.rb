module EngagementManagerStandin

#######################################################################################
def self.update_threat_priority(threat_object)

  threat_label  = threat_object.label
  threat_type   = threat_object.type.downcase
  base_priority = 0.0
  
  
  ################################################################################
  # Factor: type of threat
  
  threat_type_value = 0.0
  
  if Tewa::CONFIG['threat_type'].include?(threat_type)
    threat_type_value += Tewa::CONFIG['threat_type'][threat_type]
  end
  
  factor_value = threat_type_value * Tewa::CONFIG['threat_evaluation']['threat_type']
  
  base_priority +=  factor_value

debug_me("PRIORITY: type of threat"){[:threat_label, :threat_type, :threat_type_value,
 "Tewa::CONFIG['threat_type'][threat_type]",  
 "Tewa::CONFIG['threat_evaluation']['threat_type']", :factor_value, :base_priority]}  if $debug



  #################################################################################
  # Factor: Launch Area

  launch_area_value = 0.0

  threat_object.launch_area_label.each do |label|         # allow for multiple launch areas
    if Tewa::CONFIG['launch_area'].include?(label)
      launch_area_value += Tewa::CONFIG['launch_area'][label]
debug_me("PRIORITY: launch area"){[:label, "Tewa::CONFIG['launch_area'][label]", :launch_area_value]}  if $debug
    else
      launch_area_value += label.split('_')[0].to_f
debug_me("PRIORITY: launch area"){[:label, "label.split('_')[0].to_f", :launch_area_value]}  if $debug
    end
  end
  
  factor_value = launch_area_value * Tewa::CONFIG['threat_evaluation']['launch_area']
  
  base_priority += factor_value

debug_me("PRIORITY: launch area"){[:factor_value,
   "Tewa::CONFIG['threat_evaluation']['launch_area']", :base_priority]}  if $debug



  ################################################################################  
  # Factor: Defended Area
  
  defended_area_value = 0.0
  
  threat_object.threat_to.each do |label|                 # allow for multiple defended areas
    if Tewa::CONFIG['defended_area'].include?(label)
      defended_area_value += Tewa::CONFIG['defended_area'][label]
debug_me("PRIORITY: defended area"){[:label, "Tewa::CONFIG['defended_area'][label]", :defended_area_value]}  if $debug
    else
      defended_area_value += label.split('_')[0].to_f
debug_me("PRIORITY: defended area"){[:label, "label.split('_')[0].to_f", :defended_area_value]}  if $debug
    end
  end
  
  factor_value = defended_area_value * Tewa::CONFIG['threat_evaluation']['defended_area']
  
  base_priority += factor_value


debug_me("PRIORITY: defended area"){[:defended_area_value,
   "Tewa::CONFIG['threat_evaluation']['defended_area']", :factor_value, :base_priority]}  if $debug



  ################################################################################
  # Factor: time to impact
    
  time_to_impact  = (threat_object.impact_time - $sim_time.now) / 60.0   # convert from seconds to minutes
  
  inverse_tti     = ( 1.0 / time_to_impact )
  
  factor_value    = inverse_tti * Tewa::CONFIG['threat_evaluation']['time_until_impact']
  
  base_priority  += factor_value

  threat_object.threat_priority = base_priority


debug_me("PRIORITY: time to impact"){[:time_to_impact, :inverse_tti, 
 "Tewa::CONFIG['threat_evaluation']['time_until_impact']", :factor_value, :base_priority]}  if $debug
 
  log_this "Final priority of #{threat_label} is #{threat_object.threat_priority}"

  return threat_object.threat_priority
  
end ## end of def update_threat_priority(threat_object)

end ## module EngagementManagerStandin


