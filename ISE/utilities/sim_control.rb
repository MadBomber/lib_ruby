##############################################################
###
##  File: SimControl.rb
##  Desc: methods to control the STK simulation
##
##  Depends on global $sim_status
#

########################################
## Pause the sim at the current sim time

def pause_the_sim(an_array=[])

  log_debug "pause_the_sim"

  if 1 < an_array.length
    return nack_this("Unexpected characters followed command.")
  end

  log_this "Will pause the sim at current sim time."
  return_value = putstk('Animate * Pause')[0]

  if 'ACK' == return_value
    $sim_status.paused
    return ack_this
  end

  return nack_this("Received NACK from STK.")

end


########################################
## Start the sim at the current sim time

def start_the_sim(an_array)

  if 1 < an_array.length
    return nack_this("Unexpected characters followed command.")
  end

  log_this "Will start the sim at current sim time."
  return_value = putstk('Animate * Start Forward')[0]

  if 'ACK' == return_value
    $sim_status.running
    return ack_this
  end

  return nack_this("Received NACK from STK.")

end



##################
def reload_the_sim

  log_this "reload_the_sim"

  $unload_at = []
  SharedMemCache.set('unload_at', $unload_at)

  pause_the_sim
  putstk("Unload / *")
  
  scenario_name   = SharedMemCache.get('scenario_name')
  sc_filename_str = SharedMemCache.get('sc_filename_str')

  ra=putstk "Load / Scenario \"#{sc_filename_str}\""

  if 'NACK' == ra[0]
    msg = "STK Scenario file not found."
    msg << "#{$ENDOFLINE}\tSTK IP .... #{$STK_IP}"
    msg << "#{$ENDOFLINE}\tSTK PORT .. #{$STK_PORT}"
    msg << "#{$ENDOFLINE}\tFile ...... #{sc_filename_str}"
    msg << "#{$ENDOFLINE}\tScenario... #{scenario_name}"
    log_error msg
  end

  return_value = ra[0]

  if 'ACK' == return_value
    $sim_status.paused
    # get_stk_objects
    return ack_this
  end

  return nack_this("Received NACK from STK.")

end ## end of def reload_the_sim



