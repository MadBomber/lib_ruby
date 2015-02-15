module EngagementManagerStandin

  #####################################################################
  ## remove a destroyed ir impacted threat from the active threats hash
  
  def self.remove_threat(a_header=nil, a_message=nil)

    threat_label        = a_message.threat_label_
    
    $active_threats.delete(threat_label)  if $active_threats.include?(threat_label)

  end ## end of def self.remove_threat(a_header, a_message=nil)

end ## end of module EngagementManagerStandin

