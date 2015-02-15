module TrackToLink16
  
  ###############################################
  ## A generic callback to dump incoming messages
  def self.threat_warning(a_header, a_message=nil)

    # Label is used to determine the threat type
    threat_label = a_message.threat_label_
    log_this ">>> Threat Warning for #{threat_label}"

    # Create a new entry if it does not exist
    # CM have a 'RACM' in the label, 'RM' is missile, otherwise it is an ABT
    # Note This is a factory. 
    unless $active_tracks.include?(threat_label)
      if threat_label.is_cruise_missile?
        $active_tracks[threat_label] = CM.new(threat_label)
      elsif threat_label.is_missile?
        $active_tracks[threat_label] = Missile.new(threat_label)
      else
        $active_tracks[threat_label] = Aircraft.new(threat_label)
      end
    end

  end ## end of def self.threat_warning(a_header, a_message=nil)

end ## end of module TrackToLink16
