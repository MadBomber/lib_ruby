###############################################
###
##   File:   EngageThreat.rb
##   Desc:   Start an engagement on a threat
##
#

require 'IseMessage'

class EngageThreat < IseMessage
  def initialize
    super
    desc "Start an Engagement on a Threat"
    item(:double,          :time_)
    item(:ascii_string32,  :launcher_label_)
    item(:ascii_string32,  :threat_label_)
  end
end
