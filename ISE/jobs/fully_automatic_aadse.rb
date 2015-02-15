#!/usr/bin/env ruby
###################################################
###
##  File:  fully_automatic_aadse.rb
##  Desc:  Advanced Air Defense Synthetic Environment Simulation
##         with _NO_ Man-in-the-loop... used for running the sim
##         as fast as possible.
#

require 'IseJCL'

job_name = "fully_automated"
job_desc = "Engage all threats without man-in-the-loop (hyper-sim-time)"

if Job.find_by_name(job_name)
  the_job = IseJob.replace(job_name, job_desc)
else
  the_job = IseJob.new(job_name, job_desc)
end

the_job.basepath   = $ISE_ROOT
the_job.input_dir  = "input"
the_job.output_dir = "output/#{job_name}"


##########################################################
controller = IseModel.new(
    "FramedController",
    "Job Framed-based Controller",
    "i386-linux",
    "FramedController"
)

controller.cmd_line_param="--MC=1" # --max_frame=60"
the_job.add(controller)


##########################################################
engagement_manager_standin = IseModel.new(
  "engagement_manager_standin",
  "Functionality to stand-in for a Tactical Engagement Manager",
  "any",
  "engagement_manager_standin"
)
engagement_manager_standin.cmd_line_param  = ""

the_job.add(engagement_manager_standin)


##########################################################
battery_farm_model = IseModel.new(
  "battery_farm_model",
  "Communication wrapper around a farm of ADA batteries",
  "any",
  "battery_farm_model"
)
battery_farm_model.count           = 1 # 2
battery_farm_model.cmd_line_param  = "--auto-tbm --auto-abt" # [  "lower", "upper" ] 

the_job.add(battery_farm_model)

##########################################################
threat_farm_model = IseModel.new(
  "threat_farm_model",
  "Communication wrapper around a farm of ADA threats without real-time constraint",
  "any",
  "threat_farm_model"
)
threat_farm_model.count           = 1
threat_farm_model.cmd_line_param  = "--sim-time ba ya ga ra rm" # srbm mrbm lrbm icbm"

the_job.add(threat_farm_model)


##########################################################
interceptor_farm_model = IseModel.new(
  "interceptor_farm_model",
  "Communication wrapper around a farm of Interceptors",
  "any",
  "interceptor_farm_model"
)
interceptor_farm_model.count           = 1
interceptor_farm_model.cmd_line_param  = "" 

the_job.add(interceptor_farm_model)



##########################################################
radar_farm_model = IseModel.new(
  "radar_farm_model",
  "Ruby-based simple radar models",
  "any",
  "radar_farm_model"
)
radar_farm_model.count           = 1  # 3
radar_farm_model.cmd_line_param  = "search" # [ "lower", "upper", "search" ]

the_job.add(radar_farm_model)




=begin
##########################################################
message_logger = IseModel.new(
  "ruby_message_logger",
  "Ruby-based generic message logger",
  "any",
  "ruby_message_logger"
)

log_these_messages = %w(
  AadseRunConfiguration
  PrepareToEngageThreat
  ThreatEvaluation
  LauncherBid
  InterceptorHitTarget
  InterceptorMissedTarget
  TerminateInterceptor
  EngageThreat
  CancelEngageThreat
  ThreatEngaged
  ThreatNotEngaged
  ThreatImpacted
  ThreatWarning
  ThreatDetected
  ThreatDestroyed
)
=end


=begin
  PositionTruth
  EndEngagement
  StartFrame
  EndFrame
=end

=begin
message_logger.cmd_line_param = "-m #{log_these_messages.join(',')}"

the_job.add(message_logger)
=end


##########################################################
web_app_feeder = IseModel.new(
  "web_app_feeder",
  "Feeds IseMessages to web apps via HTTP post",
  "any",
  "web_app_feeder"
)


#TODO: Place message subscriptions in a conf file or something.
test_messages = %w(
  AadseRunConfiguration
  PrepareToEngageThreat
  InterceptorHitTarget
  InterceptorMissedTarget
  LauncherBid
  SimManagementResponse
  StartFrame
  TerminateInterceptor
  ThreatDestroyed
  ThreatEngaged
  ThreatEvaluation
  ThreatImpacted
  ThreatNotEngaged
  ThreatWarning
)
  
em_messages = %w(
  InterceptorHitTarget
  InterceptorMissedTarget
  LauncherBid
  StartFrame
  TerminateInterceptor
  ThreatEngaged
  ThreatEvaluation
  ThreatImpacted
  ThreatNotEngaged
  ThreatWarning
)

fe_messages = %w(
  AadseRunConfiguration
  InterceptorHitTarget
  InterceptorMissedTarget
  LauncherBid
  StartFrame
  TerminateInterceptor
  ThreatDestroyed
  ThreatEngaged
  ThreatImpacted
  ThreatWarning
)


web_app_feeder.count          = 1
web_app_feeder.cmd_line_param = [ # "--sev MP_MSG_URL -m SimManagementResponse,StartFrame",
                                  # "--sev TEST_MSG_URL -m #{test_messages.join(',')}",
                                  # "--sev EM_MSG_URL -m #{em_messages.join(',')}",
                                  "--sev FE_MSG_URL -m #{fe_messages.join(',')}"
                                ]

the_job.add(web_app_feeder)





the_job.register


