module BatteryFarmModel

  ###############################################
  ## Process CancelEngageThreat messages
  
  def self.cancel_engage_threat(a_header, a_message=nil)

    threat_label    = a_message.threat_label_
    launcher_label  = a_message.launcher_label_
    
    
    debug_me {[:threat_label, :launcher_label]}
    
    unless launcher_label.empty?
      return(nil) unless FARM.include?(launcher_label)
    end
    
    if $active_threats[threat_label] # Is this one of the threat's for which self is responsible?
    
      # either one of my launchers or its empty meaning all launchers
      
      if launcher_label.empty?
      
        FARM.each_pair do |launcher_label, shooter|
          result = shooter.cancel_engagement $active_threats[threat_label]
        end
      
      else
      
        shooter = FARM[launcher_label]
        result = shooter.cancel_engagement $active_threats[threat_label]

      end

      $active_threats.delete(threat_label)
      
      $do_not_engage[threat_label] = threat_label
    
    end ## if $active_threats[threat_label]
        
  end ## end of def self.cancel_engage_threat(a_header, a_message=nil)

end ## end of module BatteryFarmModel

