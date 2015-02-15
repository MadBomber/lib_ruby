#!/usr/bin/env ruby
################################################################################
###
##  File: traj_to_kml.rb
##  Desc: Generates a KML file for use with Google Earth to visualize
##        a *.traj file
##
##

require 'aadse_utilities'

puts '<?xml version="1.0" encoding="UTF-8"?>'
puts '<kml xmlns="http://earth.google.com/kml/2.1"><Document>  <name> Trajectory Projections </name>'
puts '  <Style id="trajRed">'
puts '      <LineStyle>'
puts '        <color>7f0000ff</color>'
puts '        <width>6</width>'
puts '    </LineStyle>'
puts '  </Style>'
puts '  <Style id="trajBlue">'
puts '      <LineStyle>'
puts '        <color>7fff0000</color>'
puts '        <width>6</width>'
puts '    </LineStyle>'
puts '  </Style>'
puts '  <Style id="trajGreen">'
puts '      <LineStyle>'
puts '        <color>7f00ff00</color>'
puts '        <width>6</width>'
puts '    </LineStyle>'
puts '  </Style>'







tc = 0
# loop through each (.traj file

ARGV.each do |a_file|

  label = a_file.split('.')[0]

  puts '  <Placemark>'
  puts "    <name> #{label} </name>"
  puts '    <styleUrl>#trajRed</styleUrl>'    if label.is_red_force?
  puts '    <styleUrl>#trajBlue</styleUrl>'   if label.is_blue_force?
  puts '    <LineString>      <altitudeMode>absolute</altitudeMode>'
  puts '      <coordinates>'
  
  a_file_path = Pathname.new a_file
  
  a_file_path.each_line do |a_line|
    a = a_line.split(',')
    puts "     #{a[2]},#{a[1]},#{a[3]}"
  end ## of a_file_path.each_line do |a_line|

  puts '      </coordinates>    </LineString>  </Placemark>'

end ## end of ARGV.each do |a_file|

puts '</Document></kml>'




