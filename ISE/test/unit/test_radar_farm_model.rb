#!/usr/bin/env ruby
#############################################################################
###
##  File: test_radar_farm_model.rb
##  Desc: Run some tests on the RadarFarmModel module
#



require 'radar_farm_model'

$verbose, $debug = true, true

pp RadarFarmModel::FARM

start_time = Time.now

RadarFarmModel.init



RadarFarmModel::FARM.each_pair do |k,v|
  puts "Tracking radar for #{k} is active? #{v.active}"
end



while (not $sim_time.end_of_sim?) do

  puts $sim_time.sim_time
  
  RadarFarmModel.start_frame


end

stop_time = Time.now

$stderr.puts "That took #{stop_time - start_time} seconds."

