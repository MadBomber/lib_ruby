#########################################################################
###
##  File:   interceptor_farm_model.rb (InterceptorFarmModel)
##  Desc:   This is an IseModel that simulations the behavior of a
##          collection of interceptors driven by trajectory files.
#

require 'require_all'

require 'pathname_mods'
require 'string_mods'

require 'aadse_utilities'
require 'aadse_database'

require 'Launcher'
require 'idp'
require 'load_pk_tables'


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
  $model_record.name  = 'InterceptorFarmModel'
  
  $run_model_record = OpenStruct.new
  $run_model_record.rate = 0.0
  
  require 'peerrb_module'
end


module InterceptorFarmModel

  $last_unit_id = (100 * $OPTIONS[:unit_number]) - 1

  libs = Peerrb.register(
    self.name, 
    :monte_carlo  => true,
    :framed_controller => true,
#    :timed_controller => true,
    :messages     =>  [ # Insert model-specific message symbols here
                        :PositionTruth,             # => :publish
                        :ThreatDestroyed,           # => :publish
                        :WarmUpInterceptor,         # => [:subscribe, :warm_up_interceptor]
                        :TerminateInterceptor,      # => [:subscribe, :terminate_interceptor]
                        :CancelEngageThreat,        # => [:subscribe, :cancel_engage_threat]
                        :InterceptorHitTarget,      # => :publish
                        :InterceptorMissedTarget    # => :publish
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
  

  
  interceptors = Hash.new
  
=begin
# Load all pre-defined interceptors
  $TRAJ_DIR.children(true).each do |a_filename|

    if a_filename.fnmatch?('/**/BM*.traj')
      label = a_filename.basename.to_s.split('.')[0]
      interceptors[label] = Interceptor.new(label)
      interceptors[label].load_trajectory(label)
    end
    
  end
=end
  
  
  
  log_this "Number of pre-defined interceptors loaded: #{interceptors.length}" if $verbose
  
  FARM = interceptors
  
  
  # reclaim some memory
  $idp_scenario       = nil
  $idp_batteries      = nil
  $idp_defended_aois  = nil
  $idp_launch_aois    = nil
  $idp_weapon_systems = nil
  
  GC.start


end ## module InterceptorFarmModel

# end of interceptor_farm_model.rb
#########################################################################
