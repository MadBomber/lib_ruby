###############################################
###
##   File:   CancelEngageThreat.rb
##   Desc:   Stop an engagement on a threat
##
#

require 'IseMessage'

class CancelEngageThreat < IseMessage
  def initialize
    super
    desc "Stop an Engagement on a Threat"
    item(:double,          :time_)
    item(:ascii_string32,  :launcher_label_)  # if launcher is empty, then all engagements on this threat should be canceled
    item(:ascii_string32,  :threat_label_)
  end
end
