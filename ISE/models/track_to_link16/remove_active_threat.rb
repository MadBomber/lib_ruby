module TrackToLink16

  ########################################################
  ## ThreatDestroyed and ThreatImpacted messages come here
  
  def self.remove_active_threat(a_header, a_message=nil)
    $active_tracks.delete(a_message.threat_label_) if $active_tracks.include?(a_message.threat_label_)
  end

end ## end of module TargetToLink

