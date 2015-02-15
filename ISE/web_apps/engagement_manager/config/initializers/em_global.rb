########################################################################
###
##  File:  em_global.rb
##  Desc:  Initialize the global data stores
#

###############################################
## Load external libraries 

require 'aadse_utilities' # common AADSE Utilities and MP database accessors



## $em_messages is not exposed to the user, it is for development
## TODO: Need to turn off saving the messages in producion mode
$em_messages = Array.new # Array of all messages for this run




##################################
## Establish the global data store

$em_threats       = Hash.new # of EmThreats       -- all threats for this run
$em_interceptors  = Hash.new # of EmInterceptors  -- all interceptors for this run
$em_launchers     = Hash.new # of EmLaunchers     -- all launchers for this run
$em_batteries     = Hash.new # of EmBatteries     -- all batteries for this run




#######################################################################
## Initialize the global queues

require 'em_queue'

=begin
# FIXME: This is junk!
$em_engaged		= EmQueue.new(:engaged) # Array of engaged active threats
#$em_engaged.display_title = "Serviced"

$em_unengaged	= EmQueue.new(:unengaged) # Array of unengaged active threats
#$em_unengaged.display_title = "To Be Serviced"

$em_intercepted	= EmQueue.new(:intercepted) # Array of intercepted inactive threats
$em_leaked		= EmQueue.new(:leaked) # Array of leaked inactive threats

=end

$em_queues = Hash.new

$valid_queue_names        = [:unengaged, :engaged, :intercepted, :leaked]
$valid_active_queue_names = [:unengaged, :engaged]

$valid_queue_names.each do |queue_name|
  $em_queues[queue_name] = EmQueue.new(queue_name)
end




###############################################
## Misc. global items

$em_current_threat_label      = nil # Name of the current threat.
$em_current_time_bar_duration = nil # width of time bar.




