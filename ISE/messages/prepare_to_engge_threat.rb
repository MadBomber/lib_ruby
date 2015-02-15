###############################################
###
##   File:   PrepareToEngageThreat.rb
##   Desc:   Prepare to  Engage a Threat
##           This message should invoke the can_engage? method for the TOC
##
#

require 'IseMessage'

class PrepareToEngageThreat < IseMessage
  def initialize
    super
    desc "Prepare to Engage a Threat"
    item(:double,          :time_)
    item(:ascii_string32,  :threat_label_)
  end
end
