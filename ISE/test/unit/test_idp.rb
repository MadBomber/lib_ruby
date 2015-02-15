#!/usr/bin/env ruby
##########################################################
###
##  File:  test_idp.rb
##  Desc:  Unit test for the IDP class
#

require 'rubygems'
require 'debug_me'
require 'idp'

$verbose, $debug = false, false

Idp::load_scenario(ENV['IDP_DIR']+'/new_format_scenario.xml')    # new_format_scenario
#Idp::load_scenario(ENV['IDP_DIR']+'/scenario.xml')    # new_format_scenario

debug_me

Idp::dump_scenario

puts "="*45

Idp::summary



