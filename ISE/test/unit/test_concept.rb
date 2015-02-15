#!/usr/bin/env ruby
#################################################################
###
##  File:  test_concept.rb
##  Desc:  An alpha-level test of the class concept
#

$lead_secs = 30

require 'pp'

require 'DefendedArea'
require 'Launcher'

lla = LlaCoordinate.new(32.90, 97.03, 171.3)

dallas = DefendedArea.new(  'BGDallas',
                            lla,
                            30000.0)

pp dallas
                        
toc = Toc.new(  'Dallas-HQ', 
                dallas.lla, 
                dallas)

toc.launchers << Pac3Launcher.new
toc.launchers << ThaadLauncher.new
toc.launchers << GemTLauncher.new

pp toc

targets = Array.new

red_launcher = LlaCoordinate.new(32.6207, 97.3959, 180.5)

targets << ICBM.new(red_launcher,
                    LlaCoordinate.new(32.90, 97.03, 171.3))

targets << LRBM.new(red_launcher,
                    LlaCoordinate.new(32.91, 97.2, 171.3))

targets << SRBM.new(red_launcher,
                    LlaCoordinate.new(33.93, 98.06, 171.3))


pp targets


targets.each do |t|
  puts "Is #{dallas.name} threatened by #{t.name}?  #{dallas.threatened_by? t}"
  puts "  Can #{toc.name} engage #{t.name}?  #{toc.can_engage? t}"
end
