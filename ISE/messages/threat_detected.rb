###############################################
###
##   File:   ThreatDetected.rb
##   Desc:   A thing has been detected by a radar
##
#

require 'IseMessage'

class ThreatDetected < IseMessage
  def initialize
    super
    desc "A Threat has been detected by a Radar"
    item(:double,                    :time_)
    item(:ascii_string32,            :radar_label_)
    item(:ascii_string32,            :threat_label_)
  end
end
