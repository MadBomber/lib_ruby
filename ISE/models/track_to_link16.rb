#########################################################################
###
##  File:   track_to_link16.rb (TrackToLink16)
##  Desc:   This is an IseModel which subcribes to Target 'position_truth'
##          and the Radar 'threat_warning' messages to create a Link16 Position
#

require 'require_all'

require 'pathname_mods'
require 'string_mods'

require 'aadse_utilities'
require 'aadse_database'

require 'Missile'
require 'Aircraft'
#require 'Toc'
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
  $model_record.name  = 'TrackToLink16'

  $run_model_record = OpenStruct.new
  $run_model_record.rate = 0.0

  require 'peerrb_module'
end


module TrackToLink16

  $last_unit_id = (100 * $OPTIONS[:unit_number]) - 1

  libs = Peerrb.register(
  self.name,
  :monte_carlo  => true,
  :framed_controller => true,
  #    :timed_controller => true,
  :messages     =>  [ # Insert model-specific message symbols here
                      :PositionTruth,
                      :ThreatWarning,
                      :ThreatImpacted,
                      :ThreatDestroyed,
                      :ThreatPosition
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

 
  GC.start
  

end ## module

# end of model
#########################################################################
