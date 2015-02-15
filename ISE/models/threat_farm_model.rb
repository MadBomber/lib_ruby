#########################################################################
###
##  File:   threat_farm_model.rb (ThreatFarmModel)
##  Desc:   This is an IseModel that simulations the behavior of a
##          collection of threats driven by trajectory files.
#

require 'require_all'

require 'pathname_mods'
require 'string_mods'

require 'aadse_utilities'
require 'aadse_database'

require 'Missile'
require 'Aircraft'
#require 'Launcher'
#require 'idp'
#require 'load_pk_tables'


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
  $model_record.name  = 'ThreatFarmModel'
  
  $run_model_record = OpenStruct.new
  $run_model_record.rate = 0.0
  
  require 'peerrb_module'
end


module ThreatFarmModel

  $last_unit_id = (100 * $OPTIONS[:unit_number]) - 1

  libs = Peerrb.register(
    self.name, 
    :monte_carlo  => true,
    :framed_controller => true,
#    :timed_controller => true,
    :messages     =>  [ # Insert model-specific message symbols here
                        :PositionTruth,
                        :ThreatDestroyed,
                        :ThreatImpacted,
                        :CancelEngageThreat
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
  
  process_command_line

  
  ####################################################
  ## IseRubyModel specific methods to implement the ##
  ## unique functionality of this IseRubyModel      ##
  ####################################################
  

  
  threats = Hash.new
  
  $TRAJ_DIR.children(true).each do |a_filename|

    $threat_types.each do |tt|
      fnmatch_arg = "/**/*#{tt}*.traj"
      # debug_me {:fnmatch_arg}  if $debug
      if a_filename.fnmatch?(fnmatch_arg)
        label = a_filename.basename.to_s.split('.')[0]
        threats[label] = Missile.new(label) if label.is_missile?
        threats[label] = Aircraft.new(label) if label.is_aircraft?
        log_this "... #{label} loaded as class #{threats[label].class}."
      else
        # debug_me("#{a_filename} did not match #{fnmatch_arg}")  if $debug
      end
    end
    
  end
  
  
  
  log_this "Number of threats: #{threats.length}" if $verbose
  
  FARM = threats
  


  ###############################################################
  ## Get User's man-in-the-loop selection from the selected scenario
  s = MpScenario.selected[0]

  # command line parameter trumps user's selection
  $OPTIONS[:real_time] = s.man_in_the_loop  if  $OPTIONS[:real_time].nil?

 

  ###############################################################
  # reclaim some memory
  $idp_scenario       = nil
  $idp_batteries      = nil
  $idp_defended_aois  = nil
  $idp_launch_aois    = nil
  $idp_weapon_systems = nil
  
  GC.start

  $last_realtime = Time.now   # prime the pump for the start_freme real-time process

end ## module ThreatFarmModel

# end of threat_farm_model.rb
#########################################################################
