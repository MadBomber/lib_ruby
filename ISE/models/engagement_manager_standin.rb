#!/usr/bin/env ruby
#############################################################
###
##  File: engagement_manager_standin.rb
##  Desc: A piece of prototype code to "stand-in" for the real
##        Engagement Manager

require 'require_all'

require 'pathname_mods'
require 'string_mods'

require 'aadse_utilities'
require 'aadse_database'

require 'Missile'
require 'Aircraft'
require 'idp'
require 'tewa'

require 'debug_me'



begin
  if Peerrb::VERSION
    log_this "=== Loaded by the RubyPeer ==="
    $running_in_the_peer = true
  end
rescue
  $running_in_the_peer = false
  log_this "=== Running in test mode outside of the RubyPeer ==="
  require 'dummy_connection'

  $verbose, $debug  = false, false

  $OPTIONS = Hash.new
  $OPTIONS[:unit_number] = 1

  require 'ostruct'
  $model_record = OpenStruct.new
  $model_record.name  = 'EngagementManagerStandin'

  $run_model_record = OpenStruct.new
  $run_model_record.rate = 0.0

  require 'peerrb_module'
end



module EngagementManagerStandin

  libs = Peerrb.register(
    self.name,
    :monte_carlo        => true,
    :framed_controller  => true,
    :messages           =>  [ # Insert model-specific message symbols here
                              :ThreatWarning,         # :subscribe
                              :ThreatEvaluation,      # :publish
                              :ThreatImpacted,        # :subscribe
                              :ThreatDestroyed,       # :subscribe
                              :AadseRunConfiguration  # :publish
                            ]
  )

  mattr_accessor :my_pathname
  mattr_accessor :my_directory
  mattr_accessor :my_filename
  mattr_accessor :my_lib_directory

  @@my_pathname       = Pathname.new __FILE__
  @@my_directory      = @@my_pathname.dirname
  @@my_filename       = @@my_pathname.basename.to_s
  @@my_lib_directory  = @@my_filename.split('.')[0].to_camelcase

  log_this "Entering: #{my_filename}" if $debug or $verbose
  log_this "Hello, I am: unit_number: #{$OPTIONS[:unit_number]} aka #{$model_record.name} "


  ######################################################
  ## Load libraries specific to this IseRubyModel

#  @@my_lib_directory.children.each do |lib_name|
#    if lib_name.fnmatch? '*.rb'
#      puts "#{my_filename} is loading #{lib_name} ..." if $debug
#      require lib_name
#    end
#  end
  
  require_rel @@my_lib_directory




  ####################################################
  ## IseRubyModel specific methods to implement the ##
  ## unique functionality of this IseRubyModel      ##
  ####################################################

  $mpsc = Idp::retrieve_mp_scenario_config
  
  
  debug_me {'$mpsc'} if $debug
  
    
  Idp::load_scenario($mpsc['id']['content'].to_i)
  Idp::dump_scenario if $debug
  
  pp Tewa::CONFIG

  $arc = AadseRunConfiguration.new
  $arc.mp_scenario_id_           = $mpsc['id']['content'].to_i
  $arc.mp_tewa_configuration_id_ = Tewa::RECORD.id
  $arc.mps_name_                 = $mpsc['name']
  $arc.mps_idp_name_             = $mpsc['idp-name']
  $arc.mps_sg_name_              = $mpsc['sg-name']
  $arc.mptc_name_                = Tewa::RECORD.name
  $arc.run_id_                   = $run_model_record.run_id
  $arc.sim_duration_             = $sim_time.duration
  # $arc will be published during start_frame one


  # Set the TEWA values for each Defended Area
  $idp_defended_areas.each_pair do |da_key, da|
    Tewa::CONFIG['defended_area'][da_key] = da.value
  end    

  # Set the TEWA values for each Launch Area
  $idp_launch_areas.each_pair do |la_key, la|
    Tewa::CONFIG['launch_area'][la_key] = la.value
  end
  
  
  debug_me {"Tewa::CONFIG"} if $debug
  debug_me {"$run_model_record"} if $debug

  
  # reclaim some memory
  $idp_scenario       = nil
  $idp_batteries      = nil
  $idp_weapon_systems = nil
  $idp_defended_aois  = nil
  $idp_launch_aois    = nil
  
  $idp_defended_areas = nil
  $idp_launch_areas   = nil
  
  GC.start



end ## module EngagementManagerStandin

# end of engagement_manager_standin.rb
#########################################################################


