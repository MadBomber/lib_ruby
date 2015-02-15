#!/usr/bin/env ruby
#############################################################
###
##  File: simpull.rb
##  Desc: A protocol for pulling information from a simulation
##
##  TO DO: need to do process_command
#


require 'rubygems'
require 'eventmachine'
require 'ostruct'

require 'SimTime'
require 'aadse_utilities'

$pull_commands = {
  :reset    => "Reset the simulation time.",
  :pause    => "Pause the simulation.",
  :stop     => "Stop the simulation -- same as Pause.",
  :halt     => "Halt the simulation -- same as Pause.",
  :start    => "Start the simulation beginning at the current sim time.",
  :go       => "Start the simulation beginning at the current sim time.",
  :run      => "Run the simulation beginning at the current sim time.  Same as Start.",
  :engage   => "Engage target(s) optionally with a specific fire unit.",
  :set      => "Set value of an object; example: set push 10.9.8.104 50004",
  :help     => "Display a list of command descriptions.",
  :quit     => "Terminate the loop_closer",
  :exit     => "Terminate the loop_closer",
  :get      => "Get info from the simulation on selected object classes: launchers, missiles, aircraft, time"
}





###################################################
## Engagement Manager to Simulation Pull Protocol

class SimPull < EventMachine::Connection

  attr_accessor :my_address


  ####################
  def initialize *args
    super # will call post_init
    # whatever else you want to do here
    @my_address = "NotDefinedYet"
  end ## end of def initialize *args


  #############
  def post_init
    log_this "Connection Initialized #{@my_address} - #{@signature}"
  end ## end of def post_init


  #############
  def quit? msg
    close_connection if msg =~ /quit|exit/i
  end


  #########################
  def get_command a_command
    if $pull_commands.include?(a_command)
      return a_command
    else
      send_data nack_this("Invalid command: #{a_command}")
      return nil
    end ## end of if $push_commands.include?(a_command)
  end ## end of def get_command a_command


  def process_command(command, raw_array)

    # place holder

  end ## end of def process_command


  #####################
  def receive_data data

    log_this "Received -=> '#{data}'"

    quit? data

    data_array = data.strip.split

    if data_array.length > 0

      command = get_command data_array[0].downcase.to_sym

      #return if undefined
      return nil unless command

      send_data process_command(command, data_array)

    else

      send_data nack_this("Received empty command.")

    end ## end of if a.length > 0

  end ## end of def receive_data data


  ##########
  def unbind
    log_this "Connection terminated #{@my_address} - #{@signature}"
  end ## end of def unbind


end ## end of class SimPull < EventMachine::Connection
