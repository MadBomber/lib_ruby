#####################################################
###
##  File:  idp.rb
##  Desc:  Module to encapsulate all of the processing required of
##         UIMDT IDP scenario.xml file selected by the user of the
##         Mission Planning Web App
##
## NOTE: Because thie library makes use of the XmlSimple wrappers for XML parsing, it is
##       limited in several ways.  One way is case sensitivity to tag and attribue names.
##       The opening and closing tags MUST be the same case to match.  If they are different
##       the parse will complain.  The exact tag and attribute names are used as the keys
##       into the hash.  If the case changes, as it did recently for IDP, then the
##       highly coupled hash key constants used here will break.  Looking for a way to
##       make those key case insenstive.  That would be potentially a mod to the Hash class.
#

# $verbose = false
# $debug   = false

require 'rubygems'
require 'debug_me'
require 'xmlsimple' ## GEM: XML parser

require 'aadse_utilities'
require 'aadse_database'
require 'AreaOfInterest'


module Idp

  ####################################
  ## pretty print the scenario hash to
  ## the standard out.
  def self.dump_scenario
    load_scenario       # ensure that a scenario has been loaded
    pp $idp_scenario    
  end ## end of def self.dump_scenario


  ####################################
  ## pretty print the scenario hash to
  ## the standard out.
  def self.summary(options={})
    load_scenario       # ensure that a scenario has been loaded

    puts "Scenario_Name:  #{$idp_scenario['Scenario_Name']}"
    puts "Created_On:     #{$idp_scenario['Created_On']}"
    puts "Created_By:     #{$idp_scenario['Created_By']}"
    puts "Description:    #{$idp_scenario['Description']}"
    puts
    puts "idp_scenario_path:  #{$idp_scenario['idp_scenario_path']}"
    puts
    unless $idp_scenario['mp_scenario_rec'].nil?
      puts "mp_scenario_rec:"
      max_key_length = 0
      $idp_scenario['mp_scenario_rec'].attributes.each_key do |k|
        max_key_length = k.length if k.length > max_key_length
      end
      max_key_length += 4   # MAGIC: 4 => 1 space + 3 dots for him that is the longest
      spacer = " " + "."*(max_key_length)
      $idp_scenario['mp_scenario_rec'].attributes.each_pair do |k,v|
        puts "  #{k}#{spacer[0,(max_key_length-k.length)]} #{v}"
      end
      puts
    end


    id_tag_name = 'id' if $idp_launch_aois[0].include? 'id'
    id_tag_name = 'Id' if $idp_launch_aois[0].include? 'Id'
    id_tag_name = 'ID' if $idp_launch_aois[0].include? 'ID'

    ############################################################
    puts
    puts "launch_aois:"
    $idp_launch_aois.each do |la|
      puts "  #{la[id_tag_name]}"

      if options[:launch_area] and (options[:launch_area].downcase == la[id_tag_name].downcase)
        puts "    Details:"
        puts "-"*45
        pp(la)
        puts "-"*45
      end

    end
    
    ############################################################
    puts
    puts "defended_aois:"
    $idp_defended_aois.each do |da|
      puts "  #{da[id_tag_name]}"

      if options[:defended_area] and (options[:defended_area].downcase == da[id_tag_name].downcase)
        puts "    Details:"
        puts "-"*45
        pp(da)
        puts "-"*45
      end

    end
    
    
    
#    puts "weapon_system_types:"
#    $idp_weapon_system_types.each do |wst|
#      puts "  #{wst['Id']}"
#    end

    ############################################################
    puts
    puts "batteries:"
    $idp_batteries.each_key do |b|
      puts "  #{b}"
      if options[:battery] == b.downcase
        puts "    Details:"
        puts "-"*45
        pp($idp_batteries[b])
        puts "-"*45
      end
    end

    ############################################################    
    puts
    puts "radars:"
    $idp_radars.each_key do |r|
      puts "  #{r}"
      if options[:radar] == r.downcase
        puts "    Details:"
        puts "-"*45
        pp($idp_batteries[r])
        puts "-"*45
      end

    end
    
    return nil
  end ## end of def self.summary






  ####################################
  ## Write the mp_scenario record to a
  ## config file to fix in time the configuration
  def self.write_mp_scenario_config(mps_filename=File.join(ENV['AADSE_ROOT'], 'data', 'Trajectories', 'mp_scenario.xml'))
    s = MpScenario.selected[0]
    throw :NoScenarioSelected if s.nil?
    f = File.open(mps_filename, "w")
    xml_str = s.to_xml
    f.puts xml_str
    f.close
    return xml_str
  end

  ####################################
  ## Retrieve the mp_scenario's XML config file
  ## as a hash
  def self.retrieve_mp_scenario_config(mps_filename=File.join(ENV['AADSE_ROOT'], 'data', 'Trajectories', 'mp_scenario.xml'))
    config_path = Pathname.new mps_filename
    xml_buffer = ""
    config_path.each_line { |a_line| xml_buffer << a_line }
    return XmlSimple.xml_in(xml_buffer, { 'KeyAttr' => 'name', 'ForceArray' => false }) # ["mp-scenario"]
  end

  ####################################
  ## Access the scenarios table in the
  ## Mission Planning database to get the
  ## directory within $ADDSE_ROOT/data
  ## that contains the IDP scenario's XML file.
  ## Load the scenario file into a globally accessable hash.
  ## Process that hash into other more special purpose
  ## globally accessable hashes adding data from other
  ## tables within the mission planning database.
  def self.load_scenario(which_scenario_id=0)

    return(false) if $idp_scenario
    
    if 'String' == which_scenario_id.class.to_s
    
      idp_scenario_path = Pathname.new(which_scenario_id)
    
    elsif 'Pathname' == which_scenario_id.class.to_s
    
      idp_scenario_path = which_scenario_id
    
    else

      if which_scenario_id > 0
        s = MpScenario.find(which_scenario_id)
      else
        s = MpScenario.selected[0]
      end
      
      throw :NoScenarioSelected if s.nil?

      idp_scenario_path = $IDP_DIR + s.idp_name + 'scenario.xml'

      
      unless idp_scenario_path.exist?
      
        debug_me {:idp_scenario_path}
      
        throw :IdpScenarioFileNotFound 
      end
      
    end ## end of if 'String' == which_scenario_id.class.to_s
    
    
    xml_buffer = ""
    idp_scenario_path.each_line { |a_line| xml_buffer << ( a_line.include?('udidps:') ? a_line.sub('udidps:', ''): a_line ) }

    #xml_buffer_array = xml_buffer.split("\n").map {|s| s.strip}

    #debug_me {[:xml_buffer_array]}

    $idp_scenario   = XmlSimple.xml_in(xml_buffer, { 'KeyAttr' => 'name', 'ForceArray' => false })   # ['UDIDP_Scenario']

    #debug_me {['$idp_scenario']}


    $idp_scenario['mp_scenario_rec']    = s
    $idp_scenario['idp_scenario_path']  = idp_scenario_path


    # NOTE: Force DA, LA and WS data structures to be Array because if there is only one
    #       entry in the XML file, it is returned as a hash not an array of hashes.
    #       In all cases we want an Array even if it only has one entry.
    
    
    #debug_me {"$idp_scenario['LaunchAOIs']"}
    
    
    $idp_launch_aois          = [ $idp_scenario['LaunchAOIs']['LaunchAOI'] ].flatten
    $idp_defended_aois        = [ $idp_scenario['DefendedAOIs']['DefendedAOI'] ].flatten
    
    $idp_weapon_systems       = [ $idp_scenario['Weapon_Systems']['Land_Based_Weapon_System'] ].flatten


    #debug_me {"$idp_scenario['Weapon_Systems']"}
    
    $idp_weapon_systems      += [$idp_scenario['Weapon_Systems']['Sea_Based_Weapon_System']].flatten unless $idp_scenario['Weapon_Systems']['Sea_Based_Weapon_System'].nil?
    
    $idp_weapon_system_types  = [ $idp_scenario['Weapon_System_Types']['Land_Based_Weapon_System_Type'] ].flatten
    $idp_weapon_system_types += [$idp_scenario['Weapon_System_Types']['Sea_Based_Weapon_System_Type']].flatten unless $idp_scenario['Weapon_System_Types']['Sea_Based_Weapon_System_Type'].nil?




    $idp_batteries  = Hash.new
    $idp_radars     = Hash.new

=begin
    $idp_weapon_ranges = Hash.new

    $idp_weapon_system_types.each do |wst|

      id = wst['id']

      tmp_array           = id.downcase.split('_')  # FIXME: Does not work with the new IDP naming convention
      if tmp_array.size == 1
        weapon_system_type_label = tmp_array[0]
      else
        weapon_system_type_label = tmp_array[0] + '_' + tmp_array[1]
      end

      puts "Found Weapon System Type: #{weapon_system_type_label}"

      max_range = wst["Interceptor"]["Range_Max"]["content"].to_f
      max_range *= 1000 if 'kilometers' == wst["Interceptor"]["Range_Max"]["units"].downcase

      $idp_weapon_ranges[weapon_system_type_label] = max_range unless 0.0 == max_range

    end
=end

        
    $idp_weapon_systems.each do |ws|
      
      
      if $verbose or $debug
        puts "-"*45 
        pp ws
      end
          
      ##############################
      ## Collect the shooter info ##
      ##############################
      
      id_tag_name = 'id' if ws.include? 'id'
      id_tag_name = 'Id' if ws.include? 'Id'      
      id_tag_name = 'ID' if ws.include? 'ID'      
      

      battery_label = ws[id_tag_name].downcase # This is the battery identification/name/label in Sunil's convention


      
      $idp_batteries[battery_label]  = ws
      tmp_array           = battery_label.split('_')  # Example: USA_UT_THAAD00001
      
      # NOTE: From IDP file user entered ws['type']
      #       Using naming convention to get type
      case tmp_array[1]
        when "ut" then
          weapon_system_type_label = "upper_tier"
        when "lt" then
          weapon_system_type_label = "lower_tier"
        when "sh" then
          weapon_system_type_label = "shorad"
        when "sb" then
          weapon_system_type_label = "sea_based" 
        else
          weapon_system_type_label = "unknown"
      end
      
      battery_lla = LlaCoordinate.new
      
      
      #debug_me {:ws}
      
    
      throw :LocationNotInDegrees unless 'degrees' == ws["Deployment"]["Location"]["Latitude"]["units"]
    
      battery_lla.lat  = ws["Deployment"]["Location"]["Latitude"]["content"].to_f
      battery_lla.lng  = ws["Deployment"]["Location"]["Longitude"]["content"].to_f
      battery_lla.alt  = ws["Deployment"]["Location"]["Altitude"]["content"].to_f
      battery_lla.alt  *= 1000.0 if 'kilometers' == ws["Deployment"]["Location"]["Altitude"]["units"]

      $idp_batteries[battery_label]['position'] = battery_lla

      
      # The Battery table is more like a fire_unit_type
      fu_type_rec = MpBattery.find_by_name(battery_label)      
      fu_type_rec = MpBattery.find_by_name(weapon_system_type_label) if fu_type_rec.nil?
    
      if fu_type_rec.nil?
        fu_type_rec = MpBattery.find_by_name('unknown') 
        $stderr.puts "UnknownFireUnitType: #{weapon_system_type_label} Using 'unknown'"
      end
      
      pp fu_type_rec if $debug
      
            
      $idp_batteries[battery_label]['battery_rec'] = fu_type_rec
      
      pp $idp_batteries[battery_label]['battery_rec'] if $debug
      
      puts "Battery: #{battery_label} (#{fu_type_rec.name}) -- #{fu_type_rec.desc}"  if $verbose
      
      # Only uppder_tier, lower_tier and all_tiers are supported
      blp = MpBatteryConfiguration.find(:all, :conditions => {:mp_battery_id => fu_type_rec.id })

      $idp_batteries[battery_label]['launcher_config'] = Hash.new
        
      blp.each do |x|
        launcher_name     = x.mp_launcher.name
        launcher_desc     = x.mp_launcher.desc
        launcher_qty      = x.mp_launcher_qty
        interceptor_qty   = x.mp_launcher.mp_interceptor_qty
        interceptor_name  = x.mp_launcher.mp_interceptor.name
        interceptor_desc  = x.mp_launcher.mp_interceptor.desc
        
        $idp_batteries[battery_label]['launcher_config'][launcher_name] = {
          'desc'          => launcher_desc,
          'qty'           => launcher_qty,
          # NOTE: Leaving open the idea that multiple types of interceptors can be on the same launcher
          'interceptors'  =>  { interceptor_name   => 
                                  {
                                    'qty' => interceptor_qty,
                                    'mp_interceptor_rec' => x.mp_launcher.mp_interceptor
                                  }
                              }
        }
        
        
        pp $idp_batteries[battery_label]['launcher_config'][launcher_desc] if $debug
        
        puts "  has #{launcher_qty} #{launcher_desc} launchers with #{interceptor_qty} #{interceptor_desc} interceptors each." if $verbose

      end ## end of blp.each do |x|

      #####################################
      ## Collect the tracking radar info ##
      #####################################
      
      if $verbose or $debug
        debug_me("BATTERY") {[:battery_label, "$idp_batteries[battery_label]"]}
      end
      
      if ws["Sensor"]["Sectors"].include?("Sector")
        $idp_radars[battery_label] = ws["Sensor"]["Sectors"]["Sector"]
      else
        $idp_radars[battery_label] = Hash.new
      end
      
      if $verbose or $debug
        debug_me("RADAR") {[:battery_label, "$idp_radars[battery_label]"]}
      end
      
      
      $idp_radars[battery_label]['position'] = $idp_batteries[battery_label]['position']
      
      pp $idp_radars[battery_label] if $debug
   
    end ## end of $idp_weapon_systems.each do |ws|
    
    puts "Total Tracking Radars: #{$idp_radars.length}" if $verbose






    
    ##############################################################
    ## Collect the defended aois into instances of DefendedArea ##
    ##############################################################
    
    $idp_defended_areas = Hash.new
    
    
    $idp_defended_aois.each do |da_aoi|


      id_tag_name = 'id' if da_aoi.include? 'id'
      id_tag_name = 'Id' if da_aoi.include? 'Id'      
      id_tag_name = 'ID' if da_aoi.include? 'ID'      


      da_label = da_aoi[id_tag_name]
      
      da = DefendedArea.new(da_label)
      
      da_geom = da_aoi['Geometry']

      case da_geom.keys[0]
      
        ###########################
        when 'Circle' then
          puts "found a circle area for #{da_label}" if $verbose
          da_geom = da_geom['Circle']
          
          lat     = da_geom['Center_Latitude']['content'].to_f
          lng     = da_geom['Center_Longitude']['content'].to_f
          alt     = 0.0 # TODO: Need to find altitude at a given Lat, Lng
          lla     = LlaCoordinate.new(lat,lng,alt)
          
          radius  = da_geom['Radius']['content'].to_f
          radius  *= 1000.0 if 'kilometers' == da_geom['Radius']['units']
          da.area = CircleArea.new(lla, radius)
          da.lla  = da.area.centroid    # The center of mass of the area

        ###########################
        when 'Polygon' then
          puts "found a polygon area for #{da_label}" if $verbose
          da_geom = da_geom['Polygon']['Point']

          da_geom.map! do |v|
            lat = v['Latitude']['content'].to_f
            lng = v['Longitude']['content'].to_f
            alt = 0.0 # TODO: Need to find altitude at a given Lat, Lng
            LlaCoordinate.new(lat, lng, alt)
          end
          
          da.area = PolygonArea.new(da_geom)
          da.lla  = da.area.centroid    # The center of mass of the area
                    
          # da.area.boundary.each do |b|
          #   puts "a_second_array << LlaCoordinate.new(#{b.lat}, #{b.lng}, #{b.alt})"
          # end
          
        ###########################
        else
          debug_me("WARNING: unexpected area"){[:da_label, :da_geom]}
      end

      $idp_defended_areas[da_label] = da
    
    end ## end of $idp_defended_aois.each_pair do |da_label, da_aoi|
    
    puts "Total DefendedAreas: #{$idp_defended_areas.length}" if $verbose
    

    
    ##########################################################
    ## Collect the launch aois into instances of LaunchArea ##
    ##########################################################
    
    $idp_launch_areas = Hash.new
    
    $idp_launch_aois.each do |shooter_aoi|



      id_tag_name = 'id' if shooter_aoi.include? 'id'
      id_tag_name = 'Id' if shooter_aoi.include? 'Id'      
      id_tag_name = 'ID' if shooter_aoi.include? 'ID'      


      shooter_label = shooter_aoi[id_tag_name]
      
      shooter = LaunchArea.new(shooter_label)
      
      shooter_geom = shooter_aoi['Geometry']

      case shooter_geom.keys[0]
      
        ###########################
        when 'Circle' then
          puts "found a circle area for #{shooter_label}" if $verbose
          shooter_geom = shooter_geom['Circle']
          
          lat     = shooter_geom['Center_Latitude']['content'].to_f
          lng     = shooter_geom['Center_Longitude']['content'].to_f
          alt     = 0.0 # TODO: Need to find altitude at a given Lat, Lng
          lla     = LlaCoordinate.new(lat,lng,alt)
          
          radius  = shooter_geom['Radius']['content'].to_f
          radius  *= 1000.0 if 'kilometers' == shooter_geom['Radius']['units']
          shooter.area = CircleArea.new(lla, radius)
          shooter.lla  = shooter.area.centroid    # The center of mass of the area

        ###########################
        when 'Polygon' then
          puts "found a polygon area for #{shooter_label}" if $verbose
          shooter_geom = shooter_geom['Polygon']['Point']

          shooter_geom.map! do |v|
            lat = v['Latitude']['content'].to_f
            lng = v['Longitude']['content'].to_f
            alt = 0.0 # TODO: Need to find altitude at a given Lat, Lng
            LlaCoordinate.new(lat, lng, alt)
          end
          
          shooter.area = PolygonArea.new(shooter_geom)
          shooter.lla  = shooter.area.centroid    # The center of mass of the area
          
        ###########################
        else
          debug_me("WARNING: unexpected area") {[:shooter_label, :shooter_geom]}
      end

      $idp_launch_areas[shooter_label] = shooter
    
    end ## end of $idp_launch_aois.each do |shooter_aoi|
    
    puts "Total LaunchAreas: #{$idp_launch_areas.length}" if $verbose
  
    
    return(true)
        
  end ## end of def load_scenario

end ## end of module Idp

