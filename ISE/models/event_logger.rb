#!/usr/bin/env ruby
#############################################################
###
##  File: event_logger.rb
##  Desc: Logs messages sent by loop_closer
#

require 'pp'

require 'aadse_utilities'
require 'SimPush'
require 'SimPull'
require 'PortPublisher'
require 'LlaCoordinate'

$verbose          = true
$debug            = true
$debug_cmd        = $debug
$run_event_logger = true


$EL_PUSH_IP      = ENV['IPADDRESS']
$EL_PUSH_PORT    = 50005
$EL_PULL_IP      = $EM2SIM_PULL_IP
$EL_PULL_PORT    = $EM2SIM_PULL_PORT

$SIM2LOG_PUSH = nil
$LOG2SIM_PULL = PortPublisher.new($EL_PULL_IP, $EL_PULL_PORT)



class EventLogger < SimPush

  attr_accessor :push_object
  attr_accessor :red_aircraft
  attr_accessor :red_missile
  attr_accessor :blue_aircraft
  attr_accessor :blue_interceptor
  attr_accessor :blue_launcher


  ##############
  def initialize *args
    $stdout::puts "We're initializing."
    super
    
    @push_object      = Hash.new
    @red_aircraft     = Hash.new
    @red_missiles     = Hash.new
    @blue_aircraft    = Hash.new
    @blue_interceptor = Hash.new
    @blue_launcher    = Hash.new
  end ## end of def initialize
  
  
  ################
  def log_red_aircraft
    @push_objects[:aircraft].each_value do |ra|
      log_debug "ra: #{ra.inspect}"

      # new aircraft?
      unless @red_aircraft.include?(ra[0])
        @red_aircraft[ra[0]]             = OpenStruct.new
        @red_aircraft[ra[0]].track_id    = ra[0]
        @red_aircraft[ra[0]].name        = ra[1]
        @red_aircraft[ra[0]].xpip        = [0.0, LlaCoordinate.new]
        @red_aircraft[ra[0]].pip         = []
        @red_aircraft[ra[0]].lla         = LlaCoordinate.new
        @red_aircraft[ra[0]].impact_lla  = LlaCoordinate.new
      end

      # update aircraft info
      @red_aircraft[ra[0]].lla.lat       = ra[2].to_f
      @red_aircraft[ra[0]].lla.lng       = ra[3].to_f
      @red_aircraft[ra[0]].lla.alt       = ra[4].to_f

      @red_aircraft[ra[0]].xpip[0]        = ra[5].to_f
      @red_aircraft[ra[0]].xpip[1].lat    = ra[6].to_f
      @red_aircraft[ra[0]].xpip[1].lng    = ra[7].to_f
      @red_aircraft[ra[0]].xpip[1].alt    = ra[8].to_f

      @red_aircraft[ra[0]].impact_lla.lat= ra[9].to_f
      @red_aircraft[ra[0]].impact_lla.lng= ra[10].to_f
      @red_aircraft[ra[0]].impact_lla.alt= ra[11].to_f

      @red_aircraft[ra[0]].time_to_impact= ra[12].to_f

      ## TODO: log @red_aircraft to database
      log_debug(pp(@red_aircraft.inspect?))

    end ## end of unless @red_aircraft.include?(air[0])
  end ## end of def log_red_aircraft


  ################
  def log_blue_aircraft
=begin
    @push_objects[:aircraft].each_value do |ba|
      log_debug "ba: #{ba.inspect}"

      # new aircraft?
      unless @blue_aircraft.include?(ba[0])
        @blue_aircraft[ba[0]]             = OpenStruct.new
        @blue_aircraft[ba[0]].track_id    = ba[0]
        @blue_aircraft[ba[0]].name        = ba[1]
        @blue_aircraft[ba[0]].xpip        = [0.0, LlaCoordinate.new]
        @blue_aircraft[ba[0]].pip         = []
        @blue_aircraft[ba[0]].lla         = LlaCoordinate.new
        @blue_aircraft[ba[0]].impact_lla  = LlaCoordinate.new
      end

      # update aircraft info
      @blue_aircraft[ba[0]].lla.lat       = ba[2].to_f
      @blue_aircraft[ba[0]].lla.lng       = ba[3].to_f
      @blue_aircraft[ba[0]].lla.alt       = ba[4].to_f

      @blue_aircraft[ba[0]].xpip[0]        = ba[5].to_f
      @blue_aircraft[ba[0]].xpip[1].lat    = ba[6].to_f
      @blue_aircraft[ba[0]].xpip[1].lng    = ba[7].to_f
      @blue_aircraft[ba[0]].xpip[1].alt    = ba[8].to_f

      @blue_aircraft[ba[0]].impact_lla.lat= ba[9].to_f
      @blue_aircraft[ba[0]].impact_lla.lng= ba[10].to_f
      @blue_aircraft[ba[0]].impact_lla.alt= ba[11].to_f

      @blue_aircraft[ba[0]].time_to_impact= ba[12].to_f

      ## TODO: log @blue_aircraft to database
      log_debug(pp(@blue_aircraft.inspect?))

    end ## end of @push_objects[:aircraft].each_value do |ba|
=end
  end ## end of def log_blue_aircraft


  def log_interceptors
=begin
    @push_objects[:interceptor].each_value do |bi|
      log_debug "bi: #{bi.inspect}"

      # new interceptor?
      unless @blue_launchers.include?(bi[0])
        @blue_launchers[bi[0]] = OpenStruct.new
        @blue_launchers[bi[0]].label  = bi[0]
        @blue_launchers[bi[0]].lla    = LlaCoordinate.new
        ## TODO: save other info
      end

      # update interceptor info
      @blue_launchers[bi[0]].lla.lat = bi[1].to_f
      @blue_launchers[bi[0]].lla.lng = bi[2].to_f
      @blue_launchers[bi[0]].lla.alt = bi[3].to_f
      ## TODO: save other info

      ## TODO: log @blue interceptor to database
      log_debug(pp(@blue_interceptor.inspect?))
    end ## end of @push_objects[:interceptor].each_value do |bi|
=end
  end ## end of def log_interceptors

  def log_launchers
    @push_objects[:launcher].each_value do |bl|
      log_debug "bl: #{bl.inspect}"

      # new launcher?
      unless @blue_launchers.include?(bl[0])
        @blue_launchers[bl[0]] = OpenStruct.new
        @blue_launchers[bl[0]].label  = bl[0]
        @blue_launchers[bl[0]].lla    = LlaCoordinate.new
      end

      # update launcher info
      @blue_launchers[bl[0]].lla.lat = bl[1].to_f
      @blue_launchers[bl[0]].lla.lng = bl[2].to_f
      @blue_launchers[bl[0]].lla.alt = bl[3].to_f
      @blue_launchers[bl[0]].available_rounds = bl[4].to_i
      
      ## TODO: log @blue launchers to database
      log_debug(pp(@blue_launchers.inspect?))

    end ## end of @push_objects[:launcher].each_value do |bl|
  end ## end of def log_launchers

  def log_missiles
    @push_objects[:missile].each_value do |rm|
    log_debug "rm: #{rm.inspect}"

      # new missile?
      unless @red_missiles.include?(rm[0])
        @red_missiles[rm[0]]             = OpenStruct.new
        @red_missiles[rm[0]].track_id    = rm[0]
        @red_missiles[rm[0]].name        = rm[1]
        @red_missiles[rm[0]].lla         = LlaCoordinate.new
        @red_missiles[rm[0]].xpip        = [0.0, LlaCoordinate.new]  # extroplated PIP sent by loop_closer
        @red_missiles[rm[0]].pip         = []
        @red_missiles[rm[0]].impact_lla  = LlaCoordinate.new
      end

      # update missile info
      @red_missiles[rm[0]].lla.lat       = rm[2].to_f
      @red_missiles[rm[0]].lla.lng       = rm[3].to_f
      @red_missiles[rm[0]].lla.alt       = rm[4].to_f

      @red_missiles[rm[0]].xpip[0]        = rm[5].to_f
      @red_missiles[rm[0]].xpip[1].lat    = rm[6].to_f
      @red_missiles[rm[0]].xpip[1].lng    = rm[7].to_f
      @red_missiles[rm[0]].xpip[1].alt    = rm[8].to_f

      @red_missiles[rm[0]].impact_lla.lat= rm[9].to_f
      @red_missiles[rm[0]].impact_lla.lng= rm[10].to_f
      @red_missiles[rm[0]].impact_lla.alt= rm[11].to_f

      @red_missiles[rm[0]].time_to_impact= rm[12].to_f

      ## TODO: log @red_missiles to database
      log_debug(pp(@red_missiles.inspect?))

    end ## end of @push_objects[:missile].each_value do |rm|
  end ## end of def log_missiles


  #############################
  def process_command raw_array
    the_command = get_command raw_array[0].downcase.to_sym
    the_object  = get_object  raw_array[1].downcase.to_sym
    the_value   = get_value   raw_array

    # return if undefined
    return nil unless the_command and the_object and the_value

    if :simtime == the_object
      # don't care what the command is
      @push_objects[:simtime][:now] = get_stk_sim_time the_value
      return
    end

    log_debug "Rcvd: #{raw_array.join(' ')}"

    case the_command

    when :add then
      @push_objects[the_object][the_value[0]] = the_value
    when :update then
      @push_objects[the_object][the_value[0]] = the_value
    when :delete then
      @push_objects[the_object].delete( the_value[0] )
    end

    return
  end ## end of def process raw_array


  #####################
  def receive_data data
    $stdout::puts "Event_Logger::Receive_data"
    super #run recieve_data
    
    log_red_aircraft
    log_launchers
    log_blue_aircraft
    log_interceptors
    log_missiles
  end

end ## end of class EventLogger < SimPush





####################
#def run_event_logger
  ## Initialize the event loop
  verbose_out "cntl-c to quit."

  EM.run do
    verbose_out "Attempting to start_server for #{$EL_PUSH_IP}:#{$EL_PUSH_PORT} ..."
    EM.start_server $EL_PUSH_IP, $EL_PUSH_PORT, EventLogger do |c|
      $SIM2LOG_PUSH = c
    end

    pull_cmd = "set push #{$EL_PUSH_IP} #{$EL_PUSH_PORT}#{$ENDOFLINE}"
    verbose_out pull_cmd
    #$debug = false
    $LOG2SIM_PULL.send_data(pull_cmd)
    #$debug = true
  end

  ## Event loop has terminated
  verbose_out "Done."
#end ## end of def run_event_logger


## start event logger server
#run_event_logger if $run_event_logger

