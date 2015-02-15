#!/usr/bin/env ruby
################################################################################
###
##  File: tbm_threat_generator.rb
##  Desc: Generates random TBM threats given stated constraints
##

$debug                    = false
generate_google_earth_kml = false
generate_threats_xml      = false

##########################################################################
## Load libraries

# standard gems
require 'pp'
require 'tagz'
require 'notify'

# AADSE libraries
require 'aadse_utilities'
require 'idp'

# ISE libraries
require 'LlaCoordinate'
require 'TrajectoryGenerator'
require 'AbtTrajectoryGenerator'
require 'Parameters'
require 'IdpTraj'
require 'debug_me'


xml_filename                = $TRAJ_DIR + 'threats.xml'
kml_filename                = $TRAJ_DIR + 'threats.kml'
mp_scenario_config_filename = $TRAJ_DIR + 'mp_scenario.xml'
sim_time_config_filename    = $TRAJ_DIR + 'sim_time.xml'

last_impact_delta_seconds   = -1  # Used to determine length of this simulation

##########################################################################
## General Constraints that control the production of random threats

number_of_threats = ARGV[0] ? ARGV[0].to_i : 200
time_span_seconds = ARGV[1] ? ARGV[1].to_f : $sim_time.duration   # NOTE: This is ignored in favor of last_impact_delta_seconds
safty_valve       = ARGV[2] ? ARGV[2].to_f : 0.50

if $debug

  puts "Basic Parameters are:"
  puts "  number_of_threats ... #{number_of_threats}"
  #puts "  time_span_seconds ... #{time_span_seconds}"
  puts "  safty_valve ......... #{safty_valve}"

end ## end of if $debug



#####################################
# Extract information from idp data #
#####################################

Idp::load_scenario              # loads the global idp hashes

# writes an mp_scenario.xml file to fix in time the user's selection
xml_str = Idp::write_mp_scenario_config(mp_scenario_config_filename.to_s)   

debug_me {:xml_str} if $debug


##########################################################################
## Define the threat class constrains
## :range is in meters
## :velocity is meters per second; for CM this is a constant velocity; others it is the launch velocity

threat_classes    = Array.new # An array of hashes
threat_data       = Hash.new # A Hash of hashes

threat_classes << { :name => "CM",   :range => (  50000 ..   550000), :apogee => 10000, :alt_spread =>  5000, :velocity => ( 690.0 * 1000.0 / 3600.0), :ratio => 0.25 }
threat_classes << { :name => "SRBM", :range => ( 100000 ..   512000), :apogee => 25000, :alt_spread =>  5000, :velocity => (2000.0 * 1000.0 / 3600.0), :ratio => 0.25 }
threat_classes << { :name => "MRBM", :range => ( 300000 ..  2507000), :apogee => 35000, :alt_spread =>  7000, :velocity => (2450.0 * 1000.0 / 3600.0), :ratio => 0.25 }
threat_classes << { :name => "LRBM", :range => ( 500000 ..  5000000), :apogee => 45000, :alt_spread =>  8000, :velocity => (2820.0 * 1000.0 / 3600.0), :ratio => 0.20 }
threat_classes << { :name => "ICBM", :range => (5000000 .. 12430000), :apogee => 65000, :alt_spread => 10000, :velocity => (5000.0 * 1000.0 / 3600.0), :ratio => 0.05 }
#threat_classes << { :name => "CRAM", :range => (   100 ..     2000), :velocity => 0.69, :ratio => 0.25 }

if $debug

  puts "Threats have the following configurations:"
  pp threat_classes

  puts
  puts "Launch Areas are:"
  $idp_launch_areas.each_pair do |k,v|
    puts "  #{k} a #{v.area.class} with centroid: #{v.lla}"
  end

  puts
  puts "Defended Areas are:"
  $idp_defended_areas.each_pair do |k,v|
    puts "  #{k} a #{v.area.class} with centroid: #{v.lla}"
  end

end ## end of if $debug


$unique_id = 0

def unique_id
  $unique_id += 1
  return sprintf("%03o", $unique_id) # convert to unique 3 digit octal zero-filled
end







##########################################################
## Generate the threats

start_time = Time.now

if generate_google_earth_kml

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
  kml.puts '  <Style id="trajGreem">'
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

  #####################################################################
  # Create some Placemarks for the launch and defended area's centroid

  $idp_launch_areas.each_pair do |label,v|

    if 'PolygonArea' == v.area.class.to_s

      # Create a new placemark in the KML file
      kml.puts '  <Placemark>'
      kml.puts "    <name> #{label} Centroid </name>"
      kml.puts '    <styleUrl>#trajRed</styleUrl>'
      kml.puts '    <Point>'
      kml.puts '      <coordinates>'
      kml.puts "        #{v.lla.lng},#{v.lla.lat},#{v.lla.alt}"     
      kml.puts '      </coordinates>    </Point>  </Placemark>'

      kml.puts '  <Placemark>'
      kml.puts "    <name> #{label} Boundary </name>"
      kml.puts '    <styleUrl>#trajRed</styleUrl>'
      kml.puts '    <LineString>      <altitudeMode>clampToGround</altitudeMode>'
      kml.puts '      <coordinates>'
      
      v.area.boundary.each do |b|
        kml.puts "        #{b.lng},#{b.lat},#{b.alt}"
      end
              
      kml.puts '      </coordinates>    </LineString>  </Placemark>'

    
    end

  end ## end of $idp_launch_areas.each_pair do |k,v|


  $idp_defended_areas.each_pair do |label,v|

    if 'PolygonArea' == v.area.class.to_s

      # Create a new placemark in the KML file
      kml.puts '  <Placemark>'
      kml.puts "    <name> #{label} Centroid </name>"
      kml.puts '    <styleUrl>#trajBlue</styleUrl>'
      kml.puts '    <Point>'
      kml.puts '      <coordinates>'
      kml.puts "        #{v.lla.lng},#{v.lla.lat},#{v.lla.alt}"     
      kml.puts '      </coordinates>    </Point>  </Placemark>'
    
      # Create a new placemark in the KML file
      kml.puts '  <Placemark>'
      kml.puts "    <name> #{label} Boundary </name>"
      kml.puts '    <styleUrl>#trajBlue</styleUrl>'
      kml.puts '    <LineString>      <altitudeMode>clampToGround</altitudeMode>'
      kml.puts '      <coordinates>'

      v.area.boundary.each do |b|
        kml.puts "        #{b.lng},#{b.lat},#{b.alt}"
      end
              
      kml.puts '      </coordinates>    </LineString>  </Placemark>'
    
    end

  end ## end of $idp_launch_areas.each_pair do |k,v|



end ## end of if generate_google_earth_kml


#
##
##################################################

s = MpScenario.selected[0]    # comes from the IDP library

parameters_root = $SG_DIR + s.sg_name

if parameters_root.exist?

  parameters = []

  parameters_files = find_parameters(parameters_root)
  
  number_of_parameters_files  = parameters_files.length
  notify_interval             = 10
  notify_count                = 0

  parameters_files.each do |pf|
    puts "Reading #{pf} ...."               if $debug
    
    a_parm_set = Parameters.new(pf)
    
    puts "... #{a_parm_set.missile_name}"   if $debug
        
    a_parm_set.missile_name = "CM"  if "cruisemissile" == a_parm_set.missile_name
    a_parm_set.missile_name = "CM"  if "crusemissile"  == a_parm_set.missile_name

    begin
      parameters_filename_mojo(a_parm_set)
      puts "... force_designation_ #{a_parm_set.force_designation_}"  if $debug
      puts "... weapon_category_   #{a_parm_set.weapon_category_}"    if $debug
      parameters << a_parm_set
    rescue RuntimeError => e
      puts "#{e}"
      puts "  Filepath: #{pf}"
      puts "  Ignoring file."
    end 

    case a_parm_set.force_designation_
      when :red then
        missile_name = 'R'
      when :blue then
        missile_name = 'B'
      when :pending then
        missile_name = 'Y'
      else
        missile_name = 'X'      
    end

    case a_parm_set.weapon_category_
      when :missile then
        missile_name << 'M'
      when :aircraft then
        missile_name << 'A'
      else
        missile_name << 'X'
    end
    
    missile_name << a_parm_set.missile_name.upcase + "_" + unique_id.to_s

    output_filename = "#{missile_name}.traj"

    output_filename = $TRAJ_DIR + output_filename

    traj_rv_pathname = get_traj_rv(pf) # defined in aadse_utilities

    if traj_rv_pathname
      # traj_rv.txt (IDP trajectory data) exists! 
      
      idp_trajectory = IdpTraj.new( traj_rv_pathname, a_parm_set.launch_time.to_f)
      
      debug_me {:idp_trajectory}  if $debug

      traj_rv_usable = idp_trajectory.usable?
    end



    if traj_rv_usable

      tg = idp_trajectory

      tg.write_to_file(output_filename)

      puts "Generated file #{output_filename} using IDP trajectory data from #{traj_rv_pathname} impact at: #{tg.t_track.last}" if $debug
      
      pp tg if $debug
      
      if tg.t_track.last > last_impact_delta_seconds
       last_impact_delta_seconds = tg.t_track.last
      end

    else
      # traj_rv.txt (IDP trajectory data) does not exist; use our trajectory generator
    
      if a_parm_set.weapon_category_ == :aircraft 

        if a_parm_set.missile_name.upcase != "CM"
          a_parm_set.launch_alt_m = a_parm_set.airplane_cruise_alt.to_f
          a_parm_set.impact_alt_m = a_parm_set.airplane_cruise_alt.to_f
        end

        if a_parm_set.num_way_points.to_f > 0
      
          waypoint_array = Array.new
          
          waypoint_array << [ a_parm_set.launch_lat_deg.to_f, a_parm_set.launch_lon_deg.to_f, a_parm_set.launch_alt_m.to_f, a_parm_set.airplane_init_spd.to_f]

          0.upto(a_parm_set.num_way_points.to_f - 1) do |index|
            a_str           = "a_parm_set.way_point_loc_" + index.to_s
            waypoint        = eval(a_str)
            waypoint_array << waypoint.split.map{|x| x.to_f}
          end

          waypoint_array << [ a_parm_set.impact_lat_deg.to_f, a_parm_set.impact_lon_deg.to_f, a_parm_set.impact_alt_m.to_f, a_parm_set.airplane_init_spd.to_f]

          options = { :velocity => a_parm_set.airplane_init_spd.to_f,
                      :output_filename => output_filename }

        else
          
          waypoint_array = Array.new
          
          waypoint_array << [ a_parm_set.launch_lat_deg.to_f, a_parm_set.launch_lon_deg.to_f, a_parm_set.launch_alt_m.to_f]
          waypoint_array << [ a_parm_set.impact_lat_deg.to_f, a_parm_set.impact_lon_deg.to_f, a_parm_set.impact_alt_m.to_f]

          options = { :velocity         => a_parm_set.airplane_init_spd.to_f, 
                      :cruise_alt       => a_parm_set.airplane_cruise_alt.to_f,
                      :output_filename  => output_filename
                    }
        end
        
        options.merge!({ :launch_time => a_parm_set.launch_time.to_f})
        tg = AbtTrajectoryGenerator.new( waypoint_array, options)

      else
        
        lla1 = LlaCoordinate.new( a_parm_set.launch_lat_deg, a_parm_set.launch_lon_deg, a_parm_set.launch_alt_m)
        lla2 = LlaCoordinate.new( a_parm_set.impact_lat_deg, a_parm_set.impact_lon_deg, a_parm_set.impact_alt_m)
      
        found_threat = false

        threat_classes.each do |threat_class|

          if threat_class[:name] == a_parm_set.missile_name.upcase

            options = { :velocity => threat_class[:velocity], 
                        :maximum_altitude => threat_class[:apogee], 
                        :output_filename => output_filename 
                      }

            found_threat = true

          end
        end

        if !found_threat
          options = { :output_filename => output_filename }
        end

        options.merge!({ :launch_time => a_parm_set.launch_time.to_f})
        tg = TrajectoryGenerator.new( lla1, lla2, options)

      end  ## end of if a_parm_set.weapon_category_ == :aircraft
        
      puts "Generated file #{output_filename} using our trajectory generator and data from #{pf}" if $debug

    end  ## end of if traj_rv_pathname

    if generate_google_earth_kml
    
      # Create a new placemark in the KML file
      kml.puts '  <Placemark>'
      kml.puts "    <name> #{missile_name} </name>"
      kml.puts '    <styleUrl>#trajRed</styleUrl>'
      kml.puts '    <LineString>      <altitudeMode>absolute</altitudeMode>'
      kml.puts '      <coordinates>'

      # write each trajectory point with a time offset beginning at launch_time to the traj file

      tg.trajectory.each do |a_point|
        kml.puts "     #{a_point.lng},#{a_point.lat},#{a_point.alt}"
      end ## end of tg.trajectory.each do |a_point|
               
      # close the coordinates for this placemark
      kml.puts '      </coordinates>    </LineString>  </Placemark>'

    end ## end of if generate_google_earth_kml
  
    notify_count += 1
    
    if 0 == notify_count%notify_interval
      # FIXME: This notification only appears on the web servier not the browser client
      Notify.notify "Updating Simulation", "Processed #{notify_count} of #{number_of_parameters_files} objects."
    end
      
  end  ## end of parameters_files.each do |pf|

  if parameters.empty?
    puts "WARNING: There are no UIMDT/SG parameters files defined under:"
    puts "         #{parameters_root}"
  end

else

  debug_me "The selected SG name does not exist."

end ## end of if parameters_root.exist?



##################################################
##



















##########################################
# No user editable text below this point #
##########################################

total_threats     = 0
total_percentage  = 0.0

if $debug
  puts
  puts "based on the given parameters the number of threats will be generated:"
end ## end of if $debug

threat_classes.length.times do |x|

  count                     = ( number_of_threats * threat_classes[x][:ratio] ).to_i
  threat_classes[x][:count] = count

  total_threats    += count
  total_percentage += threat_classes[x][:ratio]

  puts "  #{threat_classes[x][:name]} count: #{threat_classes[x][:count]}" if $debug

end



unless 1.0 == total_percentage
  puts "WARNING: Expecting percentage threat mix should add to 1.0 not #{total_percentage}"
end

number_of_threats = total_threats # just in case tot_count <> number_of_threats

safty_valve       = (number_of_threats * safty_valve).to_i + number_of_threats

















#######################################################

if $debug
  puts
  printf "Generating threats "
end ## end of if $debug

loop_counter = 0

while number_of_threats > 0

  launch_time         = rand(last_impact_delta_seconds) + 1
  
  launch_area_label   = $idp_launch_areas.keys[rand($idp_launch_areas.length)]
  launch_area         = $idp_launch_areas[launch_area_label]

  defended_area_label = $idp_defended_areas.keys[rand($idp_defended_areas.length)]  
  defended_area       = $idp_defended_areas[defended_area_label]

  launch_bearing  = rand(360)
  launch_range    = rand(25)  # distance in kilometers from the centroid of the area
  launch_lla      = launch_area.lla.endpoint(launch_bearing, launch_range, :units => :kms)

  impact_bearing  = rand(360)
  impact_range    = rand(25)  # distance in kilometers from the centroid of the area
  impact_lla      = defended_area.lla.endpoint(impact_bearing, impact_range, :units => :kms)

  flight_range    = ( launch_lla.distance_to(impact_lla) * 1000.0 ).to_i  # in meters

  threat_classes.length.times do |x|
    if threat_classes[x][:count] > 0
      if threat_classes[x][:range].include? flight_range

        threat_label = "#{threat_classes[x][:name]}_#{unique_id}"
        
        if 'CM' == threat_classes[x][:name]
          threat_label = 'RA' + threat_label
        else
          threat_label = 'RM' + threat_label
        end       

        threat_data[threat_label] =
        { 'time'   => launch_time,
          'label'  => threat_label,
          'kind'   => threat_classes[x][:name],
          'unit_id'=> threat_classes[x][:count],
          'launch' => { 
            'area_name' => launch_area.label,
            'latitude'  => launch_lla.lat,
            'longitude' => launch_lla.lng,
            'altitude'  => launch_lla.alt
          },
          'impact' => { 
            'area_name' => defended_area.label,
            'latitude'  => impact_lla.lat,
            'longitude' => impact_lla.lng,
            'altitude'  => impact_lla.alt
          },
          'range'  => flight_range / 1000.0,
        }
        
        if $debug
          printf "."
          $stdout.flush
        end ## end of if $debug

        number_of_threats         -= 1
        threat_classes[x][:count] -= 1
        
        # Establish place to save the trajectories
        file_name = $TRAJ_DIR + "#{threat_label}.traj"


        if 'CM' == threat_classes[x][:name]

          abt_input_array = [[ launch_lla.lat , launch_lla.lng , launch_lla.alt ],
                             [ impact_lla.lat , impact_lla.lng , impact_lla.alt ]]
        
          tg = AbtTrajectoryGenerator.new( abt_input_array,
                  :velocity         => threat_classes[x][:velocity],
                  :time_modifier    => -$sim_time.duration, # just want the last xxx seconds of the trajectory
                  :cruise_alt       => threat_classes[x][:apogee] + rand(2*threat_classes[x][:alt_spread]) - threat_classes[x][:alt_spread],
                  :time_step        =>     1.0,
                  :output_filename  => "#{file_name}",
                  :launch_time      => 0.0          # CM move too slow, start all at start of sim
             )

        else

          tg = TrajectoryGenerator.new(launch_lla, impact_lla, 
                  :initial_velocity => threat_classes[x][:velocity]*5.5,
                  :maximum_altitude => threat_classes[x][:apogee] + rand(2*threat_classes[x][:alt_spread]) - threat_classes[x][:alt_spread],
                  :time_step        => 1.0,
                  :output_filename  => "#{file_name}",
                  :launch_time      => launch_time
               )
         
        end ## end of unless 'CM' == threat_classes[x][:name]
          
        puts "#{tg.inspect}" if $debug

        if generate_google_earth_kml
        
          # Create a new placemark in the KML file
          kml.puts '  <Placemark>'
          kml.puts "    <name> #{threat_label} </name>"
          kml.puts '    <styleUrl>#trajRed</styleUrl>'
          kml.puts '    <LineString>      <altitudeMode>absolute</altitudeMode>'
          kml.puts '      <coordinates>'

          # write each trajectory point with a time offset beginning at launch_time to the traj file

          tg.trajectory.each do |a_point|
            kml.puts "     #{a_point.lng},#{a_point.lat},#{a_point.alt}"
          end ## end of tg.trajectory.each do |a_point|
                   
          # close the coordinates for this placemark
          kml.puts '      </coordinates>    </LineString>  </Placemark>'
        
        end ## end of if generate_google_earth_kml

        break

      end # end of if threat_classes[x][:range].include? flight_range
    end # end of if threat_classes[x][:count] > 0
  end # end of threat_classes.length.times do |x|

  loop_counter += 1

  if loop_counter >= safty_valve
    number_of_threats = -1
    if $debug
      puts
      puts
      puts "Safty valve tripped at loop #{loop_counter}"
    end ## end of if $debug
    break
  end

end # end of while number_of_threats > 0

if $debug
  puts
  puts
end ## end of if $debug

stop_time = Time.now

puts "#{total_threats} threats generated in #{stop_time - start_time} seconds using #{loop_counter} loops." if $debug

if generate_google_earth_kml

  # write the KML file footer lines to close out the file
  kml.puts '</Document></kml>'
  kml.close

end ## end of if generate_google_earth_kml

if generate_threats_xml

  # Create the XML file that contains the threats and only their launch and impact points
  xml = File.new(xml_filename.to_s,  "w")
  xml.puts threat_data.to_xml
  xml.close

end ## end of if generate_threats_xml

if $debug

  unless threat_data.empty?
    puts
    puts "The following threats were randomly generated:"
    threat_data.each_pair do |k,v|
      puts "  #{k} from #{v['launch']['area_name']} to #{v['impact']['area_name']} with range #{v['range']} kilometers."
    end
  end

end ## end of if $debug

##########################################################################
## Wrap it up

if $debug
  puts
  puts "Sim Duration, last planned impact at: #{last_impact_delta_seconds}"
  puts
end ## end of if $debug

st = Tagz::tagz do
      sim_time_ do
        duration_ { last_impact_delta_seconds + 5 }
      end
    end

f = File.open(sim_time_config_filename.to_s, "w")
f.puts '<?xml version="1.0" encoding="UTF-8"?>'
f.puts st
f.close


