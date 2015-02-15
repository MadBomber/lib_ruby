###############################################
###
##   File:   ThreatNotEngaged.rb
##   Desc:   Negative Acknowledge an engagement on a threat
##
#

require 'IseMessage'

class ThreatNotEngaged < IseMessage
  def initialize
    super
    desc "Negative Acknowledge an Engagement on a Threat"
    item(:double,          :time_)
    item(:ascii_string32,  :threat_label_)
    item(:ascii_string32,  :launcher_label_)
  end
end
