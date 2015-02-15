#!/usr/bin/env ruby
#############################################################################
###
##  File: test_engagement_manager_standin.rb
##  Desc: Run some tests on the EngagementManagerStandin module
#


require 'engagement_manager_standin'

$verbose, $debug = true, true



start_time = Time.now

pp $idp_defended_areas
pp $idp_launch_areas



pp Tewa::CONFIG





EngagementManagerStandin.init
EngagementManagerStandin.init_case

# go through 5 frames without any threat warnings
5.times { |x| EngagementManagerStandin.start_frame }

pp $active_threats


# do a threat warning

tw = ThreatWarning.new

tw.time_                = 7.0
tw.impact_time_         = 100.0
tw.radar_label_         = "BRSearch_001"
tw.threat_label_        = "RMMRBM_001"
tw.threat_type_         = "MRBM"
tw.defended_area_label_ = "Dubai"
tw.launch_area_label_   = "BandarAbbas"

EngagementManagerStandin.threat_warning(nil, tw)

pp $active_threats

# do 5 more frames looking for changes in the threat priority

5.times { |x| EngagementManagerStandin.start_frame }



stop_time = Time.now

$stderr.puts "That took #{stop_time - start_time} seconds."

