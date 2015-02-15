##########################################################
###
##  File: terminate_interceptor.rb
##  Desc: remove the interceptor from the farm
#

module InterceptorFarmModel

  def self.terminate_interceptor(a_header=nil, a_message=nil)
    debug_me "terminate_interceptor" if $debug
    log_event "Received #{a_message.class} at #{a_message.time_} for #{a_message.interceptor_label_}"
    FARM.delete(a_message.interceptor_label_) if FARM.include?(a_message.interceptor_label_)
  end
  
end





