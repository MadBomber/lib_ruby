###############################################
###
##   File:   ThreatPosition.rb
##   Desc:   A thing's position accoring to a radar
##
#

require 'IseMessage'

class ThreatPosition < IseMessage
  def initialize
    super
    desc "Threat Position According to a Radar"
    item(:double,                    :time_)
    item(SamsonMath::Vec3(:double),  :position_)
    item(SamsonMath::Vec3(:double),  :velocity_)
    item(SamsonMath::EulerAngles,    :attitude_)
    item(:ascii_string32,            :radar_label_)
    item(:ascii_string32,            :threat_label_)
  end
end
