

# TODO: get rid of the hard coded IDP radar data and get the stuff direct from the IDP.xml file


require "LlaCoordinate"
require "Radar"

kml_filename = "radar.kml"



battery_lla    = Array.new
battery_sensor = Array.new
max_range      = Array.new

battery_lla    << LlaCoordinate.new(25.432, 56.2594, 0.0)
battery_sensor << StaringRadar.new( "lower_tier_5", battery_lla.last, [0.0, 100000.0], [55.0, 30.0], [30.0, 30.0] )

battery_lla    << LlaCoordinate.new(25.11225, 56.323964, 0.0)
battery_sensor << StaringRadar.new( "lower_tier_6", battery_lla.last, [0.0, 100000.0], [90.0, 30.0], [30.0, 30.0] )

battery_lla    << LlaCoordinate.new(24.025, 53.728, 0.0)
battery_sensor << StaringRadar.new( "lower_tier_7", battery_lla.last, [0.0, 100000.0], [20.0, 30.0], [30.0, 30.0] )

battery_lla    << LlaCoordinate.new(24.0156, 53.1959, 0.0)
battery_sensor << StaringRadar.new( "lower_tier_8", battery_lla.last, [0.0, 100000.0], [0.0, 30.0], [30.0, 30.0] )

battery_lla    << LlaCoordinate.new(23.516, 52.6123, 0.0)
battery_sensor << StaringRadar.new( "lower_tier_9", battery_lla.last, [0.0, 100000.0], [0.0, 30.0], [30.0, 30.0] )

battery_lla    << LlaCoordinate.new(24.75176, 55.333006, 0.0)
battery_sensor << StaringRadar.new( "upper_tier_1", battery_lla.last, [255000.0, 655000.0], [60.0, 30.0], [5.7, 3.0] )

battery_lla    << LlaCoordinate.new(25.35, 55.43, 0.0)
battery_sensor << StaringRadar.new( "lower_tier_1", battery_lla.last, [0.0, 100000.0], [30.0, 30.0], [30.0, 30.0] )

battery_lla    << LlaCoordinate.new(23.401546, 54.631572, 0.0)
battery_sensor << StaringRadar.new( "upper_tier_2", battery_lla.last, [255000.0, 655000.0], [20.0, 30.0], [5.7, 3.0] )

battery_lla    << LlaCoordinate.new(24.8568, 55.329, 0.0)
battery_sensor << StaringRadar.new( "lower_tier_2", battery_lla.last, [0.0, 100000.0], [340.0, 30.0], [30.0, 30.0] )

battery_lla    << LlaCoordinate.new(23.41958, 52.601753, 0.0)
battery_sensor << StaringRadar.new( "upper_tier_3", battery_lla.last, [255000.0, 655000.0], [0.0, 30.0], [5.7, 3.0] )

battery_lla    << LlaCoordinate.new(24.428333, 54.458083, 0.0)
battery_sensor << StaringRadar.new( "lower_tier_3", battery_lla.last, [0.0, 100000.0], [30.0, 30.0], [30.0, 30.0] )

battery_lla    << LlaCoordinate.new(23.4872, 54.6238, 0.0)
battery_sensor << StaringRadar.new( "lower_tier_4", battery_lla.last, [0.0, 100000.0], [5.0, 30.0], [30.0, 30.0] )







# Create a KML file to visualize the threat trajectories
kml = File.new(kml_filename.to_s,  "w")

# write the KML preample lines
kml.puts '<?xml version="1.0" encoding="UTF-8"?>'
kml.puts '<kml xmlns="http://earth.google.com/kml/2.1"><Document>  <name> Trajectory Projections </name>'
kml.puts '  <Style id="trajRed">'
kml.puts '      <LineStyle>'
kml.puts '        <color>7f0000ff</color>'
kml.puts '        <width>6</width>'
kml.puts '    </LineStyle>'
kml.puts '  </Style>'
kml.puts '  <Style id="trajGreen">'
kml.puts '      <LineStyle>'
kml.puts '        <color>7f00ff00</color>'
kml.puts '        <width>6</width>'
kml.puts '    </LineStyle>'
kml.puts '  </Style>'
kml.puts '  <Style id="trajBlue">'
kml.puts '      <LineStyle>'
kml.puts '        <color>7fff0000</color>'
kml.puts '        <width>6</width>'
kml.puts '    </LineStyle>'
kml.puts '  </Style>'



battery_sensor.each do |bs|

  if bs.range.max == 100000.0
    max_range = 30000
  elsif bs.range.max == 655000.0
    max_range = 400000
  end

  # Create a new placemark in the KML file
  kml.puts '  <Placemark>'
  kml.puts "    <name> #{bs.name} </name>"
  kml.puts '    <styleUrl>#trajBlue</styleUrl>'
  kml.puts '    <LineString>'
  kml.puts '      <coordinates>'

  pt1 = bs.lla
  pt2 = pt1.endpoint( bs.azimuth_min, bs.range.max/1000.0)
  pt3 = pt1.endpoint( bs.azimuth_max, bs.range.max/1000.0)

  # write each trajectory point with a time offset beginning at launch_time to the traj file

  kml.puts "     #{pt1.lng},#{pt1.lat},#{pt1.alt}"
  kml.puts "     #{pt2.lng},#{pt2.lat},#{pt2.alt}"
  kml.puts "     #{pt3.lng},#{pt3.lat},#{pt3.alt}"
  kml.puts "     #{pt1.lng},#{pt1.lat},#{pt1.alt}"

           
  # close the coordinates for this placemark
  kml.puts '      </coordinates>    </LineString>  </Placemark>'

  kml.puts '  <Placemark>'
  kml.puts "    <name> #{bs.name} </name>"
  kml.puts '    <styleUrl>#trajGreen</styleUrl>'
  kml.puts '    <LineString> '
  kml.puts '      <coordinates>'

  pt1 = bs.lla
  pt2 = bs.lla.endpoint( bs.azimuth_min, max_range/1000.0)
  pt3 = bs.lla.endpoint( bs.azimuth_max, max_range/1000.0)

  # write each trajectory point with a time offset beginning at launch_time to the traj file

  kml.puts "     #{pt1.lng},#{pt1.lat},#{pt1.alt}"
  kml.puts "     #{pt2.lng},#{pt2.lat},#{pt2.alt}"
  kml.puts "     #{pt3.lng},#{pt3.lat},#{pt3.alt}"
  kml.puts "     #{pt1.lng},#{pt1.lat},#{pt1.alt}"


           
  # close the coordinates for this placemark
  kml.puts '      </coordinates>    </LineString>  </Placemark>'  


end


# write the KML file footer lines to close out the file
kml.puts '</Document></kml>'
kml.close







