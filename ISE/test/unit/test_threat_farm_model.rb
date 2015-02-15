#!/usr/bin/env ruby
#############################################################################
###
##  File: test_threat_farm_model.rb
##  Desc: Run some tests on the ThreatFarmModel module
#



require 'threat_farm_model'

$verbose, $debug = true, true

pp $sim_time

start_time = Time.now

while (not $sim_time.end_of_sim?) do

  puts $sim_time.sim_time

  ThreatFarmModel::FARM.each_pair do |threat_label, threat|
    log_event "Launch #{threat_label}" if $sim_time.sim_time == threat.launch_time

    if threat.life_span.include? $sim_time.sim_time
      lla = threat.current_position
      log_event "Flying #{threat_label} at #{lla}" unless lla.nil?
    end
    
    
    if $sim_time.sim_time == threat.impact_time
      log_event "Impact #{threat_label}"
      ThreatFarmModel::FARM.delete(threat_label)
      log_this "Threats left: #{ThreatFarmModel::FARM.length}"
    end
  end

  $sim_time.advance_time

end

stop_time = Time.now

$stderr.puts "That took #{stop_time - start_time} seconds."

