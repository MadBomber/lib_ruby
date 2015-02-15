#!/usr/bin/env ruby
################################################################################
###
##  File: csv_to_kml.rb
##  Desc: Generates a KML file for use with Google Earth to visualize
##        ground clamped routes between two points
##
##  Input CSV comes from either STDIN or from text files on the command line or both.
##


puts '<?xml version="1.0" encoding="UTF-8"?>'
puts '<kml xmlns="http://earth.google.com/kml/2.1"><Document>  <name> Trajectory Projections </name>'
puts '  <Style id="trajRed">'
puts '      <LineStyle>'
puts '        <color>7f0000ff</color>'
puts '        <width>6</width>'
puts '    </LineStyle>'
puts '  </Style>'







tc = 0
# loop through csv file

ARGF.each do |a_line|

  column = a_line.split(',')
  tt     = column[1]
  tc    += 1
  lp_lat = column[2]
  lp_lng = column[3]
  ip_lat = column[4]
  ip_lng = column[5]

  puts '  <Placemark>'
  puts "    <name> #{tt}_#{tc} </name>"
  puts '    <styleUrl>#trajRed</styleUrl>'
  puts '    <LineString>      <altitudeMode>clampToGround</altitudeMode>'
  puts '      <coordinates>'
  puts "     #{lp_lng},#{lp_lat},0.0"
  puts "     #{ip_lng},#{ip_lat},0.0"
  puts '      </coordinates>    </LineString>  </Placemark>'

end

puts '</Document></kml>'




