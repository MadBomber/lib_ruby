#########################################################################
###
##  File:   sim_frame_controller.rb (ThreatFarmModel)
##  Desc:   The master controller for the simulation
#


require 'pathname_mods'
require 'string_mods'

require 'aadse_utilities'
require 'aadse_database'

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
  $model_record.name  = 'SimFrameController'
  
  $run_model_record = OpenStruct.new
  $run_model_record.rate = 0.0
  
  require 'peerrb_module'
end


module SimFrameController

  $last_unit_id = (100 * $OPTIONS[:unit_number]) - 1

  libs = Peerrb.register(
    self.name, 
    :monte_carlo        => true,
    :framed_controller  => true,
#    :timed_controller  => true,
    :messages           =>  [ # Insert model-specific message symbols here
                        :SimManagement,
                        :SimManagementResponse,
                        :StartFrame,
                        :EndFrame
                      ]
  )



  mattr_accessor :my_pathname
  mattr_accessor :my_directory
  mattr_accessor :my_filename
  mattr_accessor :my_lib_directory

  @@my_pathname       = Pathname.new __FILE__
  @@my_directory      = @@my_pathname.dirname
  @@my_filename       = @@my_pathname.basename.to_s
  @@my_lib_directory  = @@my_directory + @@my_filename.split('.')[0].to_camelcase

  log_this "Entering: #{my_filename}" if $debug or $verbose
  log_this "Hello, I am: unit_number: #{$OPTIONS[:unit_number]} aka #{$model_record.name} "


  ######################################################
  ## Load libraries specific to this IseRubyModel

  @@my_lib_directory.children.each do |lib_name|
    if lib_name.fnmatch? '*.rb'
      log_this "#{my_filename} is loading #{lib_name} ..." if $debug or $verbose
      require lib_name
    end
  end
  
  process_command_line

  
  ####################################################
  ## IseRubyModel specific methods to implement the ##
  ## unique functionality of this IseRubyModel      ##
  ####################################################
  

end ## module SimFrameController

# end of sim_frame_controller.rb
#########################################################################
