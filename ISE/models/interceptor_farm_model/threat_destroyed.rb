##########################################################
###
##  File: threat_destroyed.rb
##  Desc: Handel the ThreatDestroyed message
#

module InterceptorFarmModel

  def self.threat_destroyed(a_header=nil, a_message=nil)
    puts "threat_destroyed"
    log_event "Received #{a_message.class} at #{a_message.time_} for #{a_message.threat_label_}"
    FARM.delete(a_message.threat_label_) if FARM.include?(a_message.threat_label_)
  end
  
end





