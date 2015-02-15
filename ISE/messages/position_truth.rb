###############################################
###
##   File:   PositionTruth.rb
##   Desc:   A things true position accoring to itself
##
#

require 'IseMessage'

class PositionTruth < IseMessage
  def initialize
    super
    desc "True Position According to Self"
    item(:double,                    :time_)
    item(SamsonMath::Vec3(:double),  :position_)
    item(SamsonMath::Vec3(:double),  :velocity_)
    item(SamsonMath::EulerAngles,    :attitude_)
    item(:ascii_string32,            :label_)
  end
end
