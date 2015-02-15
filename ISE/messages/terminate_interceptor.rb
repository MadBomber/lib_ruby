###############################################
###
##   File:   TerminateInterceptor.rb
##   Desc:   Shut down the interceptor or self destruct the thing
##
#

require 'IseMessage'

class TerminateInterceptor < IseMessage
  def initialize
    super
    desc "Shut down the interceptor or self destruct the thing"
    item(:double,          :time_)
    item(:bool,            :self_destruct_)
    item(:ascii_string32,  :interceptor_label_)
    item(:ascii_string32,  :launcher_label_)
    item(:ascii_string32,  :target_label_)
  end
end
