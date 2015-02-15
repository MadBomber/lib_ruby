##########################################################
###
##  File: warm_up_interceptor.rb
##  Desc: Add the interceptor to the farm
#

module InterceptorFarmModel

  def self.warm_up_interceptor(a_header=nil, a_message=nil)
    puts "warm_up_interceptor"
    log_event "Received #{a_message.class} at #{a_message.time_} for #{a_message.interceptor_label_}"
    log_this "#{a_message}"
    
    FARM[a_message.interceptor_label_] = Interceptor.new(
      a_message.interceptor_label_,
      LlaCoordinate.new(a_message.launch_lla_),
      LlaCoordinate.new(a_message.impact_lla_),
      a_message.launch_time_,
      a_message.flight_time_
    )
   
    FARM[a_message.interceptor_label_].target_label       = a_message.threat_label_
    FARM[a_message.interceptor_label_].launcher_label     = a_message.launcher_label_
    FARM[a_message.interceptor_label_].engagement_result  = a_message.engagement_result_
    
    FARM[a_message.interceptor_label_].load_trajectory(a_message.interceptor_label_)

    $interceptor_threat_xref[a_message.interceptor_label_] = a_message.threat_label_
  end
  
end





