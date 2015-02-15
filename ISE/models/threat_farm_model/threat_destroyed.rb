##########################################################
###
##  File: threat_destroyed.rb
##  Desc: Handel the ThreatDestroyed message
#

module ThreatFarmModel

  def self.threat_destroyed(a_header=nil, a_message=nil)
    debug_me "threat_destroyed"   if $debug
    log_event "Received #{a_message.class} at #{a_message.time_} for #{a_message.threat_label_}"
    if FARM.include?(a_message.threat_label_)
      FARM.delete(a_message.threat_label_)
      ce = CancelEngageThreat.new
      ce.threat_label_    = a_message.threat_label_
      ce.launcher_label_  = ""  # All launchers should terminated their flying interceptors
      ce.time_            = $sim_time.now
      ce.publish
    end
  end
  
end





