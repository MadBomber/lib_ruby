#!/usr/bin/env ruby
##########################################################################
###
##  File:  test_default_search_radar.rb
##  Desc:  build a generic search radar from the data provided in config/project.ini
##         and see if it can detect the threats in the current scenario.
#
$verbose, $debug = false,false

require 'pathname'

if ARGV.empty? or '--help' == ARGV[0] or '-h' == ARGV[0]
  puts "Usage: #{Pathname.new(__FILE__).basename} threat_label|--all|--help|-h"
  puts "       Use the --all option to process all current threats against the default radar."
  exit
end

threat_label  = ARGV.shift
traj_path     = Pathname.new(ENV['TRAJ_DIR']) + "#{threat_label}.traj"

unless traj_path.exist?
  threats = Array.new
  traj_path.dirname.children.each do |c|
    threats << c.basename.to_s.split('.')[0] if c.basename.fnmatch?("*.traj")
  end
  unless "--all" == threat_label
    puts "ERROR: #{threat_label} does not have a *.traj file."
    puts "       try the --all option of one of these:"
    puts "         #{threats.join(', ')}"
    exit
  end
else
  threats = [threat_label]
end


require 'iniparse'

require 'aadse_utilities'
require 'Radar'


############################################################
## Redefine the RotatingRadar can_detect? method
## __ASSUMPTION__ is that it rotates fast enought that
## azimuth and elevation do not matter
=begin
class RotatingRadar
  def can_detect?(thing)
    return within_range?(thing)
  end
end
=end

$OPTIONS = Hash.new

  #######################################################
  ## At this point all require libraries both global and
  ## specific to radar_farm_model have been loaded.

  config_file = Pathname.new(ENV['AADSE_ROOT']) + 'config' + 'project.ini'
  
  begin
    $OPTIONS[:config] = IniParse.open(config_file.to_s)['radar_farm_model']
  rescue
    $OPTIONS[:config] = nil
  end
  
  debug_me('FROM-CONFIG'){:$OPTIONS}
  
  if $OPTIONS[:config].nil?
    $OPTIONS[:config]              = Hash.new
    $OPTIONS[:config]['detections_before_warning'] = 5       # this many detection events before a warning is issued
    $OPTIONS[:config]['latitude']  =     23.9731356935962    # decimal degrees (WGS84 projection)
    $OPTIONS[:config]['longitude'] =     53.9333200248623    # decimal degrees (WGS84 projection)
    $OPTIONS[:config]['altitude']  =     60.0                # meters 
    $OPTIONS[:config]['range_min'] =   3000.0                # meters (minimum distance at which a radar can detect a threat; threats closer than this are not detectable)
    $OPTIONS[:config]['range_max'] = 740000.0                # meters (maximum distance at which a radar can detect a threat)
    debug_me('USING HARDCODED DEFAULTS'){"$OPTIONS[:config]"}
  end

############################################################################
## Build the default radar using the stuff from the config file


lla             = LlaCoordinate.new(
                    $OPTIONS[:config]['latitude'],      # decimal degrees
                    $OPTIONS[:config]['longitude'],     # decimal degrees
                    $OPTIONS[:config]['altitude']       # meters
                  )
range_min       = $OPTIONS[:config]['range_min']        # meters
range_max       = $OPTIONS[:config]['range_max']        # meters
range_data      = [range_min, range_max]
rpm             =     60.0                # revolutions per minute (RPM)
beam_width      =      2.0                # width of beam in degrees
elevation_data  = [0.0, 45.0, 45.0, 0.0]  ## [min, max, width, rate]

sr  = RotatingRadar.new(
    'BRSR_001',
    lla,                    ## LlaCoordinate or [lat, long, alt] decimal degrees and meters
    range_data,
    rpm,
    beam_width,
    elevation_data
)

sr.active = true  # turn the search radar on

pp sr

detection_events = Hash.new

threats.each do |threat_label|

  detection_events[threat_label] = Array.new

  traj_path     = Pathname.new(ENV['TRAJ_DIR']) + "#{threat_label}.traj"

  traj_path.each_line do |a_line|
    columns = a_line.split(',')
    t = columns[0]
    lla = LlaCoordinate.new(columns[1].to_f, columns[2].to_f, columns[3].to_f)
        
    puts "time: #{t} #{threat_label} is at #{lla}" if $debug
    
    if sr.can_detect?(lla)
      detection_events[threat_label] << [t, lla]
    end
    
  end

end ## end of threats.each do |threat_label|

puts
puts

puts "Detection Events Summary By Threat"
puts "=================================="

detection_events.each_pair do |k,v|
  puts
  puts "--------------" + "-"*(k.length)
  puts "threat_label: #{k}"
  puts "first event:  #{v.first.pretty_inspect}"
  puts "last event:   #{v.last.pretty_inspect}"

  pp v if $debug
end


