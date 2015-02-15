###############################################
###
##   File:   ThreatEngaged.rb
##   Desc:   Acknowledge an engagement on a threat
##
#

require 'IseMessage'

class ThreatEngaged < IseMessage
  def initialize
    super
    desc "Acknowledge an Engagement on a Threat"
    item(:double,          :time_)
    item(:double,          :launch_time_)
    item(:double,          :impact_time_)
    item(:INT16,           :launcher_rounds_available_)    
    item(:INT16,           :battery_rounds_available_)    
    item(:ascii_string32,  :threat_label_)
    item(:ascii_string32,  :launcher_label_)
    item(:ascii_string32,  :battery_label_)    
    item(:ascii_string32,  :interceptor_label_)
  end
end
