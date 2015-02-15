###############################################
###
##   File:   LauncherBid.rb
##   Desc:   A launcher's bid against a threat
##
#

require 'IseMessage'

class LauncherBid < IseMessage
  def initialize
    super
    desc "A launcher's Bid Against a Threat"
    item(:double,          :time_)
    item(:double,          :first_launch_time_)
    item(:double,          :first_intercept_time_)
    item(:double,          :last_launch_time_)
    item(:double,          :last_intercept_time_)
    item(:double,          :bid_factor_)
    item(:INT16,           :launcher_rounds_available_)    
    item(:INT16,           :battery_rounds_available_)    
    item(:ascii_string32,  :threat_label_)
    item(:ascii_string32,  :launcher_label_)
    item(:ascii_string32,  :battery_label_)
  end
end
