###############################################
###
##   File:   ThreatEvaluation.rb
##   Desc:   A thing's evaluation priority as calculated by the TEWA magic
##
#

require 'IseMessage'

class ThreatEvaluation < IseMessage
  def initialize
    super
    desc "Am Evaluation of the 'priority' of a Threat"
    item(:double,                    :time_)
    item(:double,                    :impact_time_)
    item(:double,                    :priority_)
    item(:ascii_string32,            :threat_label_)
    item(:ascii_string32,            :threat_type_)
    item(:ascii_string32,            :defended_area_label_)
    item(:ascii_string32,            :launch_area_label_)
  end
end
