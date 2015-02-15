###############################################
###
##   File:   WarmUpInterceptor.rb
##   Desc:   Start the count down to launch
##
#

require 'IseMessage'

class WarmUpInterceptor < IseMessage
  def initialize
    super
    desc "Prepare an Interceptor for Launch"
    item(:double,                   :time_)
    item(:double,                   :launch_time_)
    item(:double,                   :flight_time_)
    item(SamsonMath::Vec3(:double), :launch_lla_)
    item(SamsonMath::Vec3(:double), :impact_lla_)
    item(:ascii_string32,           :interceptor_label_)
    item(:ascii_string32,           :launcher_label_)
    item(:ascii_string32,           :threat_label_)
    item(:ascii_string32,           :engagement_result_)
  end
end
