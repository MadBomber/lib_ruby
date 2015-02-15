###############################################
###
##   File:   InterceptorMissedTarget.rb
##   Desc:   A confirmation that an interceptor has missed its intended target
##
#

require 'IseMessage'

class InterceptorMissedTarget < IseMessage
  def initialize
    super
    desc "A confirmation that an interceptor has missed its intended target"
    item(:double,          :time_)
    item(:ascii_string32,  :threat_label_)
    item(:ascii_string32,  :interceptor_label_)
    item(:ascii_string32,  :launcher_label_)
  end
end
