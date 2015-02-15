#########################################################################
###
##  File:   radar_farm_model.rb (RadarFarmModel)
##  Desc:   This is an IseModel that simulations the behavior of a
##          collection of radars driven by IseMessages.
#

require 'require_all'

require 'pathname_mods'
require 'string_mods'
require 'iniparse'

require 'aadse_utilities'
require 'aadse_database'

require 'Radar'
require 'Missile'
require 'Aircraft'
require 'idp'
require 'mp_threat'

############################################################
## Redefine the RotatingRadar can_detect? method
## __ASSUMPTION__ is that it rotates fast enought that
## azimuth and elevation do not matter
class RotatingRadar
  def can_detect?(thing)
    return within_range?(thing)
  end
end



begin
  if Peerrb::VERSION
    log_this "=== Loaded by the RubyPeer ==="
    $running_in_the_peer = true
  end
rescue
  $running_in_the_peer = false
  log_this "=== Running in test mode outside of the RubyPeer ==="
  require 'dummy_connection'

  $verbose, $debug  = false, false

  $OPTIONS = Hash.new
  $OPTIONS[:unit_number] = 1

  require 'ostruct'
  $model_record = OpenStruct.new
  $model_record.name  = 'RadarFarmModel'

  $run_model_record = OpenStruct.new
  $run_model_record.rate = 0.0

  require 'peerrb_module'
end


module RadarFarmModel

  $last_unit_id = (100 * $OPTIONS[:unit_number]) - 1

  libs = Peerrb.register(
  self.name,
  :monte_carlo        => true,
  :framed_controller  => true,
  #    :timed_controller  => true,
  :messages     =>  [ # Insert model-specific message symbols here
                      :PositionTruth,
                      :ThreatPosition,
                      :ThreatDetected,
                      :ThreatWarning
                    ]
  )



  mattr_accessor :my_pathname
  mattr_accessor :my_directory
  mattr_accessor :my_filename
  mattr_accessor :my_lib_directory

  @@my_pathname       = Pathname.new __FILE__
  @@my_directory      = @@my_pathname.dirname
  @@my_filename       = @@my_pathname.basename.to_s
  @@my_basename_sans_rb = @@my_filename.split('.')[0]
  @@my_lib_directory  = @@my_basename_sans_rb.to_camelcase

  log_this "Entering: #{my_filename}" if $debug or $verbose
  log_this "Hello, I am: unit_number: #{$OPTIONS[:unit_number]} aka #{$model_record.name} "


  ######################################################
  ## Load libraries specific to this IseRubyModel

#  @@my_lib_directory.children.each do |lib_name|
#    if lib_name.fnmatch? '*.rb'
#      puts "#{my_filename} is loading #{lib_name} ..." if $debug
#      require lib_name
#    end
#  end
  
  require_rel @@my_lib_directory

  process_command_line


  ####################################################
  ## IseRubyModel specific methods to implement the ##
  ## unique functionality of this IseRubyModel      ##
  ####################################################


  #######################################################
  ## At this point all require libraries both global and
  ## specific to radar_farm_model have been loaded.

  config_file = Pathname.new(ENV['AADSE_ROOT']) + 'config' + 'project.ini'
  
  begin
    $OPTIONS[:config] = IniParse.open(config_file.to_s)[@@my_basename_sans_rb]
  rescue
    $OPTIONS[:config] = nil
  end
  
  debug_me('FROM-CONFIG'){:$OPTIONS}  if $debug
  
  if $OPTIONS[:config].nil?
    $OPTIONS[:config]              = Hash.new
    $OPTIONS[:config]['detections_before_warning'] = 5       # this many detection events before a warning is issued
    $OPTIONS[:config]['latitude']  =     23.9731356935962    # decimal degrees (WGS84 projection)
    $OPTIONS[:config]['longitude'] =     53.9333200248623    # decimal degrees (WGS84 projection)
    $OPTIONS[:config]['altitude']  =     60.0                # meters 
    $OPTIONS[:config]['range_min'] =   3000.0                # meters (minimum distance at which a radar can detect a threat; threats closer than this are not detectable)
    $OPTIONS[:config]['range_max'] = 740000.0                # meters (maximum distance at which a radar can detect a threat)
    debug_me('USING HARDCODED DEFAULTS'){"$OPTIONS[:config]"}  if $debug
  end

  #####################################################
  ## Load the entire (its small) mp_threat table
  
  $mpt = Hash.new
    
  MpThreat.find(:all).each do |v|
    $mpt[v.name.downcase] = v
  end
  



  ####################################################
  ## Configure the radars from the IDP laydown

  Idp::load_scenario
  Idp::dump_scenario if $debug

  radars = Hash.new
  
  idp_has_search_radars_defined = false

  $idp_radars.each_pair do |id, r|

    $radar_types.each do |radar_type|

      if id.downcase.include?(radar_type)

        position = r['position']

        range_center  = r["Range_Center"]["content"].to_f  # => "50"
        range_extent  = r['Range_Extent']["content"].to_f
        range_max     = range_center + range_extent
        range_min     = range_center - range_extent
        range_min     = 0.0 if range_min < 0.0
        range_min    *= 1000.0 if r["Range_Center"]["units"] == "kilometers"
        range_max    *= 1000.0 if r["Range_Center"]["units"] == "kilometers"
        
        range_data    = [range_min, range_max]
        
        elevation_extent = r["Elevation_Extent"]["content"].to_f # => "30"
        elevation_center = r["Elevation_Center"]["content"].to_f # => "30"

        azimuth_center = r["Azimuth_Center"]["content"].to_f # => "30"
        azimuth_extent = r["Azimuth_Extent"]["content"].to_f # => "30"


        if 'search' == radar_type
          idp_has_search_radars_defined = true


          radars[id]  = RotatingRadar.new(
              id,
              position,               ## LlaCoordinate or [lat, long, alt] decimal degrees and meters
              range_data,             ## [min, max]
              30.0,                   ## RPM
              2.0,                    ## beam width
              [0.0, 45.0, 45.0, 0.0]  ## [min, max, width, rate]
          )

          debug_me("IDP-HAS-SEARCH-RADAR"){"radars[id]"}  if $debug
          
        else

          radars[id] = StaringRadar.new( 
            id,                                 ## Label by which the radar is known
            position,                           ## LlaCoordinate
            range_data,                         ## [min, max] meters
            [azimuth_center, azimuth_extent],   ## [azomuth, width]
            [elevation_center, azimuth_extent]  ## [elevation, width]
          )

        end
        
        radars[id].active = true  # turn all tracking radard on

      end ## end of if id.downcase.include?(radar_type)

    end ## end of $radar_types.each do |radar_type|

  end ## end of $idp_radars.each_pair do |id, r|


  if $radar_types.include?('search')

    # ensure at least one search radar in the sim
    unless idp_has_search_radars_defined
    
      debug_me("Using Default Radar"){:idp_has_search_radars_defined}  if $debug

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

      radars['search_radar']  = RotatingRadar.new(
          'BRSR_001',
          lla,                    ## LlaCoordinate or [lat, long, alt] decimal degrees and meters
          range_data,
          rpm,
          beam_width,
          elevation_data
      )

      radars['search_radar'].active = true  # turn the search radar on

      pp radars['search_radar']

    end ## end of unless radars.include?('search_radar')

  end ## end of if $radar_types.include?('search')


  debug_me("Number of radars") {"radars.length"}  if $debug

  FARM = radars
  
  DETECTIONS_BEFORE_WARNING = $OPTIONS[:config]['detections_before_warning']   # radar should detect the threat this many times before issuing a warning   # radar should detect the threat this many times before issuing a warning
  
  # reclaim some memory
  $idp_scenario       = nil
  $idp_batteries      = nil
  $idp_defended_aois  = nil
  $idp_launch_aois    = nil
  $idp_weapon_systems = nil
  
  GC.start



end ## module RadarFarmModel

# end of radar_farm_model.rb
#########################################################################
