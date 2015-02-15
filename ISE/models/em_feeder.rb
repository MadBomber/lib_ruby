#########################################################################
###
##  File:   em_feeder.rb (EmFeeder)
##  Desc:   This is a specialization of the standard IseRubyMode WebAppFeeder.  Its
##          purpose is to feed IseMessages into the EngagementManager.  The difference
##          is that the StartFrame message is only passed to the EM on odd frames.
#

require 'SimTime'
require 'debug_me'
require 'rest_client'     # full RESTful interaction with a web site
require 'require_all'

$sim_time = SimTime.new

begin
  if Peerrb::VERSION
    # FIXME: Logging is broken because it relied on AADSE
    #log_this "=== Loaded by the RubyPeer ==="
    $running_in_the_peer = true
  end
rescue
  $running_in_the_peer = false
  # FIXME: Logging is broken because it relied on AADSE
  #log_this "=== Running in test mode outside of the RubyPeer ==="
  require 'dummy_connection'

  $verbose, $debug  = false, false
  
  $OPTIONS = Hash.new
  $OPTIONS[:unit_number] = 1
  
  require 'ostruct'
  $model_record = OpenStruct.new
  $model_record.name  = 'EmFeeder'
  
  $run_model_record = OpenStruct.new
  $run_model_record.rate = 0.0
  
  require 'peerrb_module'
end


module EmFeeder

  $last_unit_id = (100 * $OPTIONS[:unit_number]) - 1

  libs = Peerrb.register(
    self.name, 
    :monte_carlo  => true,
    :framed_controller => true,
    :timed_controller => true,
    :messages     =>  [ # model specific messages are loaded in process_command_line
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

  # FIXME: Logging is broken because it relied on AADSE
  #log_this "Entering: #{my_filename}" if $debug or $verbose
  #log_this "Hello, I am: unit_number: #{$OPTIONS[:unit_number]} aka #{$model_record.name} "


  ######################################################
  ## Load libraries specific to this IseRubyModel
  
  require_rel @@my_lib_directory

  process_command_line


  ######################################################
  ## Define the web applications receiving controller for IseMessage
  ## post events.

  url       = $OPTIONS[:url]
  # FIXME: This is broken because it relied on AADSE
  #username  = 'aadse'
  #password  = username

  $web_app = RestClient::Resource.new(url) #, username, password)

end ## module EmFeeder

# end of web_app_feeder.rb
#########################################################################
