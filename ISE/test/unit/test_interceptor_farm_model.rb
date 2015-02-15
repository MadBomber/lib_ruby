#!/usr/bin/env ruby
#############################################################################
###
##  File: test_interceptor_farm_model.rb
##  Desc: Run some tests on the ThreatFarmModel module
#



require 'interceptor_farm_model'

$verbose, $debug = true, true

pp $sim_time

start_time = Time.now

InterceptorFarmModel.init



InterceptorFarmModel::FARM.each_pair do |k,v|
  puts "#{k} --=>#{v.engagement_result}<=-- (#{v.engagement_result.class})"
end



while (not $sim_time.end_of_sim?) do

  puts $sim_time.sim_time
  
  InterceptorFarmModel.start_frame

=begin
  InterceptorFarmModel::FARM.each_pair do |interceptor_label, interceptor|
    log_event "Launch #{interceptor_label}" if $sim_time.sim_time == interceptor.launch_time

    if interceptor.life_span.include? $sim_time.sim_time
      lla = interceptor.current_position
      log_event "Flying #{interceptor_label} at #{lla}" unless lla.nil?
    end
    
    
    if $sim_time.sim_time == interceptor.impact_time
      log_event "Impact #{interceptor_label}"
      InterceptorFarmModel::FARM.delete(interceptor_label)
      log_this "Interceptors left: #{InterceptorFarmModel::FARM.length}"
    end
  end

  $sim_time.advance_time
=end



end

stop_time = Time.now

$stderr.puts "That took #{stop_time - start_time} seconds."

