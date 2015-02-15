############################################################
###
##  File: em_queue_controller.rb
##  Desc: Mess with Dewayne's head
##
#


class EmQueuesController < ApplicationController
  
  # These queue names are defined in the config/initializers/em_globals.rb file
  QUEUE_NAMES          = $valid_queue_names
  ACTIVE_QUEUE_NAMES   = $valid_active_queue_names          # These queues are displayed to the user
  INACTIVE_QUEUE_NAMES = QUEUE_NAMES - ACTIVE_QUEUE_NAMES   # These queues are not displayed to the user


  ################################################################
  ## index is called when?  from where?

  def index
        
  end ## def index
  
  
  ###########################################################################
  ## Return the queues to their initial condition
  def self.reset
  
    puts 'Resetting all queues!'
    
    QUEUE_NAMES.each {|qn| $em_queues[qn].reset }
    
  end ## def reset
  

  ###############################
  # Update all the necessary queues for this threat
  # called from threats_controller
  def self.update_threat(threat_label)
  
    threat_status = $em_threats[threat_label].status
    
#    debug_me{[:threat_label, :threat_status, "$em_threats[threat_label]"]}
    
    queue_names = (ACTIVE_QUEUE_NAMES + [threat_status]).flatten.compact.uniq
    
#    debug_me {:queue_names}
      
    queue_names.each do |queue_name|
#      debug_me("QQQ") {:queue_name}
      $em_queues[queue_name].update_threat(threat_label)
#      debug_me "ZZZ"
    end
    
  end ## def update_threat(threat_label)

end ## class EmQueuesController < ApplicationController
