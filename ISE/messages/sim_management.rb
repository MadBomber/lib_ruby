###############################################
###
##   File:   SimManagement.rb
##   Desc:   Service Request/Response for Simulation Management
##
#

require 'IseMessage'

class SimManagement < IseMessage
  attr_accessor :valid_services
  def initialize
    super
    desc "Service Request/Response for Simulation Management"
    item(:double,                    :time_)
    item(:ACE_UINT32,                :request_id_)
    item(:ascii_string12,            :service_requested_)
    
    max_service_name_length = 12
    
    @valid_services = [ #1...5....0..  #
                        'start',       # start a paused sim
                        'resume',      # .. same as start
                        'pause',       # pause a running sim
                        'stop',        # .. same as pause
                        'sim_status',  # return the sim status
                        'frame_on',    # add 'me' to the needs frames list
                        'frame_off'    # remove 'me' from the needs frames list
                      ]
                        
    @valid_services.each do |sn|
      throw :ServiceNameTooLong if sn.length > max_service_name_length
    end

  end
end

