###############################################
###
##   File:   ThreatWarning.rb
##   Desc:   A thing's position accoring to a radar
##
#

require 'IseMessage'

class ThreatWarning < IseMessage
  def initialize
    super
    desc "A Trajectory Track has been Determined to Threaten a DefendedArea"
    item(:double,                    :time_)
    item(:double,                    :impact_time_)
    item(:ascii_string32,            :radar_label_)
    item(:ascii_string32,            :threat_label_)
    item(:ascii_string32,            :threat_type_)
    item(:ascii_string32,            :defended_area_label_)
    item(:ascii_string32,            :launch_area_label_)
  end
end
