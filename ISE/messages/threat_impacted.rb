###############################################
###
##   File:   ThreatImpacted.rb
##   Desc:   Target has impacted the ground
##
#

require 'IseMessage'

class ThreatImpacted < IseMessage
  def initialize
    super
    desc "Target Has Impacted the Ground"
    item(:double,          :time_)
    item(:ascii_string32,  :threat_label_)
  end
end
