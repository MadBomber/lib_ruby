#!/usr/bin/env ruby
#############################################################
###
##  File: SimPush.rb
##  Desc: A protocol for pushing information from a simulation
##
#

require 'rubygems'
require 'eventmachine'
require 'ostruct'

require 'SimTime'
require 'aadse_utilities'

$push_commands = {
  :add    => "Add new data -- same as update.",
  :delete => "Delete an object.",
  :update => "Update with new data -- same as add.",
}

$push_objects = {
  :launcher => {},
  :simtime  => {:now => ""},
  :missile  => {},
  :aircraft => {}
}

###################################################
## Simulation Push Protocol

class SimPush < EventMachine::Connection

  attr_accessor :my_address
  attr_accessor :line_buffer


  ####################
  def initialize *args
    super # will call post_init
    # whatever else you want to do here
    @my_address   = "NotDefinedYet"
    @data_buffer  = ""
  end ## end of def initialize *args


  #############
  def post_init
    log_this "Connection Initialized #{@my_address} - #{@signature}"
  end ## end of def post_init


  #########################
  def get_command a_command
    if $push_commands.include?(a_command)
      return a_command
    else
      log_error "The command '#{a_command}' is not implemented."
      return nil
    end ## end of if $push_commands.include?(a_command)
  end ## end of def get_command a_command


  ########################
  def get_object an_object
    if $push_objects.include?(an_object)
      return an_object
    else
      log_error "The object '#{an_object}' is not implemented."
      return nil
    end ## end of unless $push_objects.include?(the_object)
  end ## end of def get_object an_object


  #######################
  def get_value raw_array
    raw_array.delete_at(0) # delete the command
    raw_array.delete_at(0) # delete the object name
    return raw_array
  end ## end of def get_value raw_array


  ##############################
  def get_stk_sim_time the_value
    a_stk_time_str  = the_value.join(' ')       # STK time format has double quotes around it
    return Time.parse(a_stk_time_str[1, a_stk_time_str.length - 2]) # remove the double quotes
  end ## end of def get_value raw_array

  
  #############################
  def process_command raw_array
    #default method; may be replaced

    the_command = get_command raw_array[0].downcase.to_sym
    the_object  = get_object  raw_array[1].downcase.to_sym
    the_value   = get_value   raw_array

    # return if undefined
    return nil unless the_command and the_object and the_value

    if :simtime == the_object
      # don't care what the command is
      $push_objects[:simtime][:now] = get_stk_sim_time the_value
      return
    end

    log_debug "Rcvd: #{raw_array.join(' ')}"

    case the_command

    when :add then
      $push_objects[the_object][the_value[0]] = the_value
    when :update then
      $push_objects[the_object][the_value[0]] = the_value
    when :delete then
      $push_objects[the_object].delete( the_value[0] )
    end

    return
  end ## end of def process raw_array


  #####################
  def receive_data data

    log_debug "Received -=> #{data}"

    @data_buffer << data

    while @data_buffer.include?($ENDOFLINE)
      data_lines = @data_buffer.split($ENDOFLINE)
      line_cnt = data_lines.length
      unless $ENDOFLINE == @data_buffer[0-$ENDOFLINE.length, $ENDOFLINE.length]
        @data_buffer = data_lines.last
        line_cnt -= 1
      else
        @data_buffer = ""
      end
      line_cnt.times do |inx|
        a_line = data_lines[inx]
        log_debug "Processing: #{a_line}"
        a = a_line.strip.split
        process_command(a)  if a.length >= 3
      end
    end
  end ## end of def receive_data data


  ###########
  def unbind
    log_this "Connection terminated #{@my_address} - #{@signature}"
  end ## end of def unbind


end ## end of class SimPush < EventMachine::Connection
