###############################################
###
##   File:   SimManagementResponse.rb
##   Desc:   Service Request/Response for Simulation Management
##
#

require 'SimManagement'

class SimManagementResponse < SimManagement
  def initialize
    super
    desc "Service Response for Simulation Management"
    item(:ascii_string12,            :service_response_)
  end
end


