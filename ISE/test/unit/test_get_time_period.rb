#!/usr/bin/env ruby
##################################################################
###
##  File: test_get_time_period.rb
##  Desc: Unit testing for the get_time_period method of StkMessage
#

require 'aadse_utilities'
require 'StkMessage'
require 'Target'

SharedMemCache.new

tgt = SharedMemCache.get 'RMSRBM_001'


$STK_IP = '10.9.8.2'
$STK_PORT = 5001

link_to_stk

$debug_cmd = true
$debug_stk = true

time_period = get_time_period(tgt.sop, true)

log_this "WARNING: Could not get time period of #{@name} from STK" if time_period.empty?








time_period = get_time_period






