#####################################################################
###
##  File:  ControlMessages.rb
##  Desc:  Control messages by definition are SamsonHeaders with a message_length_ of zero
##
## TODO: Need to get rid of the entire concept of a control message, its just a dataless message
#

require 'IseDatabase'
require 'SamsonHeader'
require 'SimMsgType'


class ControlMessage < SamsonHeader

  # FIXME: need way to manipulate header options like flags_
  def initialize(data=nil)
    super
    
    if data && 'Symbol' == data.class.to_s
      @type_ = SimMsgType.type_(data)
      @desc  = SimMsgType.desc_(data)
    else
      message_key   = self.class.to_s
      app_message   = AppMessage.find_by_app_message_key(message_key)
      
      if app_message.nil? # Nothing in the IseDatabase
        app_message = AppMessage.new
        app_message.description = "A 'control' message"
        app_message.message_key = message_key
        app_message.save
      end
      
      @app_msg_id_  = app_message.id
      @desc         = app_message.description
      @type_        = SimMsgType.type_(:CONTROL)
    end
    
    @run_id_          = $run_record.id
    @peer_id_         = $run_peer_record.id
    @unit_id_         = $OPTIONS[:unit_number]
    @message_length_  = 0
    
    unless 0 == @flags_
      $stderr.puts 
      $stderr.puts "INTERNAL SYSTEM ERROR: from #{__FILE__}   at line: #{__LINE__}"
      $stderr.puts "    @flags_ not zero"
      $stderr.puts "    @flags_: #{@flags}"
      $stderr.puts 
      $stderr.puts 
    end
    
  end ## end of def initialize
  
  
  ############################
  def self.subscribe my_method
    puts "Entering ControlMessage subscribe"  if $debug or $verbose or $debug_io
  
    my_symbol = self.to_s.to_underscore.upcase.to_sym
    
    if $control_message.include? my_symbol
      $connection.subscribe_special my_symbol, my_method
    else
      puts "INTERNAL DESIGN FLAW: Cannot subscribe #{my_symbol} from the ControlMessage class."
    end 
    
    puts "leaving ControlMessage subscribe"  if $debug or $verbose or $debug_io
  end
  
  
  
  ################
  def self.publish
    puts "Entering ControlMessage publish"  if $debug or $verbose or $debug_io
    
    my_symbol = self.to_s.to_underscore.upcase.to_sym
    
    if $control_message.include? my_symbol
      $control_message[my_symbol].pack_message
      $connection.send_message $control_message[my_symbol].out
    else
      puts "INTERNAL DESIGN FLAW: Cannot Publish #{my_symbol} from the ControlMessage class."
    end 
    
    puts "leaving ControlMessage publish"  if $debug or $verbose or $debug_io
  end

end ## end of class ControlMessage

################################################################
## Some control messages from SimMsgType
## The use of the type_ and the C++ SimMSgType.h file
## are being phased out in favor of the AppMessage table in the
## IseDatabase

$control_message = Hash.new
$control_message[:ROUTE]                              = ControlMessage.new :ROUTE
$control_message[:SUBSCRIBE]                          = ControlMessage.new :SUBSCRIBE
$control_message[:DATA]                               = ControlMessage.new :DATA
$control_message[:RECOVERABLE_ERROR_STATUS_RESPONSE]  = ControlMessage.new :RECOVERABLE_ERROR_STATUS_RESPONSE
$control_message[:FATAL_ERROR_STATUS_RESPONSE]        = ControlMessage.new :FATAL_ERROR_STATUS_RESPONSE
$control_message[:OK_STATUS_RESPONSE]       = ControlMessage.new :OK_STATUS_RESPONSE
$control_message[:STATUS_REQUEST]           = ControlMessage.new :STATUS_REQUEST
$control_message[:START_FRAME]              = ControlMessage.new :START_FRAME
$control_message[:END_FRAME_REQUEST]        = ControlMessage.new :END_FRAME_REQUEST
$control_message[:END_FRAME_OK_RESPONSE]    = ControlMessage.new :END_FRAME_OK_RESPONSE
$control_message[:END_FRAME_ERROR_RESPONSE] = ControlMessage.new :END_FRAME_ERROR_RESPONSE
$control_message[:END_FRAME_COMMAND]    = ControlMessage.new :END_FRAME_COMMAND
$control_message[:START_SIMULATION]     = ControlMessage.new :START_SIMULATION
$control_message[:END_SIMULATION]       = ControlMessage.new :END_SIMULATION
$control_message[:START_CASE]           = ControlMessage.new :START_CASE
$control_message[:END_CASE]             = ControlMessage.new :END_CASE
$control_message[:BREAKWIRE]            = ControlMessage.new :BREAKWIRE
$control_message[:IGNITION]             = ControlMessage.new :IGNITION
$control_message[:INVOKE_REQUEST]       = ControlMessage.new :INVOKE_REQUEST
$control_message[:INVOKE_RESPONSE]      = ControlMessage.new :INVOKE_RESPONSE
$control_message[:LOCATE_REQUEST]       = ControlMessage.new :LOCATE_REQUEST
$control_message[:LOCATE_RESPONSE]      = ControlMessage.new :LOCATE_RESPONSE
$control_message[:HELLO]                = ControlMessage.new :HELLO
$control_message[:INIT]                 = ControlMessage.new :INIT
$control_message[:GOODBYE]              = ControlMessage.new :GOODBYE
$control_message[:D2D_CONNECT]          = ControlMessage.new :D2D_CONNECT
$control_message[:GOODBYE_REQUEST]      = ControlMessage.new :GOODBYE_REQUEST
$control_message[:DISPATCHER_COMMAND]   = ControlMessage.new :DISPATCHER_COMMAND
$control_message[:LOG_CHANNEL_STATUS]   = ControlMessage.new :LOG_CHANNEL_STATUS
$control_message[:ADVANCE_TIME_REQUEST] = ControlMessage.new :ADVANCE_TIME_REQUEST
$control_message[:TIME_ADVANCED]        = ControlMessage.new :TIME_ADVANCED



################################################################
## Control messages from the AppMessage table of the IseDatabase

class Init                  < ControlMessage; end   ## :INIT
#class InitCase            < ControlMessage; end   ## :START_CASE
#class InitCaseComplete    < ControlMessage; end   ## 

class AdvanceTimeRequest    < ControlMessage; end   ## :ADVANCE_TIME_REQUEST
class TimeAdvanced          < ControlMessage; end   ## :TIME_ADVANCED

#class StartFrame            < ControlMessage; end   ## :START_FRAME
class EndFrameRequest       < ControlMessage; end   ## :END_FRAME_REQUEST
class EndFrameCommand       < ControlMessage; end   ## :END_FRAME_COMMAND

class EndFrameOkResponse    < ControlMessage; end   ## :END_FRAME_OK_RESPONSE
class EndFrameErrorResponse < ControlMessage; end   ## :END_FRAME_ERROR_RESPONSE

class StatusRequest         < ControlMessage; end   ## :STATUS_REQUEST
class OkStatusResponse      < ControlMessage; end   ## :OK_STATUS_RESPONSE

#class EndCase             < ControlMessage; end   ## :END_CASE
#class EndCaseComplete     < ControlMessage; end   ## 

#class EndRun                < ControlMessage; end   ## 
#class EndRunComplete        < ControlMessage; end   ## 

## end of file: ControlMessages.rb
##################################

