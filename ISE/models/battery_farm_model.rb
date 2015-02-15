#########################################################################
###
##  File:   battery_farm_model.rb (BatteryFarmModel)
##  Desc:   This is an IseModel that simulations the behavior of a
##          collection of fire unit batteries.  A fire unit battery may
##          consist of various types of launchers with different
##          ordinance load outs, a tactical operations center and / or
##          sensors.
##
#

require 'ostruct'
require 'require_all'

require 'pathname_mods'
require 'string_mods'
require 'Radar'

require 'aadse_utilities'
require 'aadse_database'

require 'Missile'
require 'Aircraft'
require 'Toc'
require 'Launcher'
require 'idp'
require 'load_pk_tables'



begin
  if Peerrb::VERSION
    log_this "=== Loaded by the RubyPeer ==="
    $running_in_the_peer = true
  end
rescue
  require 'ise_logger'
  ISE::Log.new
    
  $running_in_the_peer = false
  log_this "=== Running in test mode outside of the RubyPeer ==="
  require 'dummy_connection'

  $OPTIONS = Hash.new
  $OPTIONS[:unit_number] = 1

  require 'ostruct'
  $model_record = OpenStruct.new
  $model_record.name  = 'BatteryFarmModel'
  
  ISE::Log.progname = $model_record.name

  $run_model_record = OpenStruct.new
  $run_model_record.rate = 0.0

  require 'peerrb_module'

end

module BatteryFarmModel

  $last_unit_id = (100 * $OPTIONS[:unit_number]) - 1

  libs = Peerrb.register(
  self.name,
  :monte_carlo  => true,
  :framed_controller => true,
  #    :timed_controller => true,
  :messages     =>  [ # Insert model-specific message symbols here
                      :ThreatWarning,             # :subscribe
                      :ThreatImpacted,            # :subscribe
                      :ThreatDestroyed,           # :subscribe
                      :LauncherBid,               # :publish
                      :EngageThreat,              # :subscribe
                      :CancelEngageThreat,        # :subscribe
                      :ThreatEngaged,             # :subscribe
                      :ThreatNotEngaged,          # :subscribe
                      :PrepareToEngageThreat      # :subscribe
                    ]
  )



  mattr_accessor :my_pathname
  mattr_accessor :my_directory
  mattr_accessor :my_filename
  mattr_accessor :my_lib_directory

  @@my_pathname       = Pathname.new __FILE__
  @@my_directory      = @@my_pathname.dirname
  @@my_filename       = @@my_pathname.basename.to_s
  @@my_lib_directory  = @@my_filename.split('.')[0].to_camelcase

  ISE::Log.debug "Entering: #{my_filename}"
  ISE::Log.debug "unit_number: #{$OPTIONS[:unit_number]} aka #{$model_record.name} "


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

  Idp::load_scenario
  Idp::dump_scenario if $debug

  load_pk_tables

  debug_me "Number of batteries: #{$idp_batteries.length}" if $verbose

  launcher_hash = Hash.new
  launcher_cnt  = 0

  $idp_batteries.each_pair do |k,v|
    
    id_variable = 'id' if v.include? 'id'
    id_variable = 'Id' if v.include? 'Id'
    
    battery_label = v[id_variable].downcase
    battery_lla   = v['position']

    range_center = v["Sensor"]["Sectors"]["Sector"]["Range_Center"]["content"].to_f
    range_extent = v["Sensor"]["Sectors"]["Sector"]["Range_Extent"]["content"].to_f
    range_center *= 1000.0 if "kilometers" == v["Sensor"]["Sectors"]["Sector"]["Range_Center"]["units"]
    range_extent *= 1000.0 if "kilometers" == v["Sensor"]["Sectors"]["Sector"]["Range_Extent"]["units"]
    
    range_max    = range_center + range_extent
    range_min    = 0.0 

    range_array  = [range_min, range_max]
    
    azimuth_center = v["Sensor"]["Sectors"]["Sector"]["Azimuth_Center"]["content"].to_f
    azimuth_extent = v["Sensor"]["Sectors"]["Sector"]["Azimuth_Extent"]["content"].to_f

    azimuth_array  = [azimuth_center, azimuth_extent]

    elevation_center = v["Sensor"]["Sectors"]["Sector"]["Elevation_Center"]["content"].to_f
    elevation_extent = v["Sensor"]["Sectors"]["Sector"]["Elevation_Extent"]["content"].to_f

    elevation_array  = [elevation_center, elevation_extent]


    battery_sensor = StaringRadar.new( battery_label, battery_lla, range_array, azimuth_array, elevation_array )


    # $battery_types.each do |battery_type|

      # if k.downcase.include?(battery_type)

        if $debug
          puts "="*45
          pp v
          puts "-"*35
        end

        battery_fire_unit_id = k

        battery_lla = v['position']

        launcher_config = v['launcher_config']

        if $debug
          debug_me "Battery Fire Unit ID: #{battery_fire_unit_id}"
          debug_me "          Located At: #{battery_lla} LLA"
          pp launcher_config
          debug_me "  has #{launcher_config.length} launcher type(s)"
        end

        launcher_config.each_pair do |lc_key, lc_value|
          launcher_cnt += 1

          if $debug
            puts "-"*10
            debug_me {[:lc_key, :lc_value]}
          end

          lc_qty      = lc_value['qty']

          # NOTE: Assumes a homogenious load out consistent with current Launcher class
          #       A ThaadLauncher only has Thaad interceptors
          #       A Pac3Launcher only has Pac3 interceptors
          #       A GemTLauncher only has GemT interceptors, etc.

          interceptor_data = lc_value['interceptors'][lc_key]
          
          unless interceptor_data
            error_desc  = "If there is no interceptor data that matches lc_key, then the convention "
            error_desc += "that the launcher class/type and the interceptor class/type are the same "
            error_desc += "has been violated the in Mission Planning Launcher's table.  '#{lc_key}' is not the same as '#{lc_value['interceptors'].keys}'"
            $stderr.puts
            $stderr.puts
            debug_me(:tag=>"ERROR in MP's Launcher Configuration", :file=>$stderr) {[:error_desc, :lc_key, :lc_value]}
            $stderr.puts
            $stderr.puts
            exit -1
          end

          lc_msl_qty  = interceptor_data['qty']

          klass_name = lc_key.downcase.capitalize + 'Launcher'

          mp_interceptor_record = MpInterceptor.find_by_name(lc_key.downcase)

          if mp_interceptor_record
            standard_pk_air   = mp_interceptor_record.pk_air
            standard_pk_space = mp_interceptor_record.pk_space
            max_range         = mp_interceptor_record.max_range_meters
          end

          mp_launcher_record = MpLauncher.find_by_name(lc_key.downcase)

          if mp_launcher_record
            tbm_doctrine = mp_launcher_record.tbm_doctrine.name.to_sym
            abt_doctrine = mp_launcher_record.abt_doctrine.name.to_sym
          else
            tbm_doctrine = nil
            abt_doctrine = nil
          end

          
          if $debug
            debug_me "Launcher Type: #{lc_key}  Qty: #{lc_qty} with #{lc_msl_qty} interceptors each"
            debug_me "Launcher Class Name: #{klass_name}"
          end

          # follow the naming convent established by the Launcher class
          launcher_label   = "BL#{lc_key}_#{launcher_cnt}"
          launcher_hash[launcher_label] = Kernel.const_get(klass_name).new(launcher_label, battery_lla)

      

          # Over-ride the default initial conditions
          launcher_hash[launcher_label].battery_label     = battery_fire_unit_id
          launcher_hash[launcher_label].battery_size      = lc_qty
          launcher_hash[launcher_label].standard_rounds   = lc_msl_qty
          launcher_hash[launcher_label].cost_factor       = interceptor_data['mp_interceptor_rec'].cost.to_f
          launcher_hash[launcher_label].standard_pk_air   = standard_pk_air
          launcher_hash[launcher_label].standard_pk_space = standard_pk_space
          launcher_hash[launcher_label].max_range         = max_range
          launcher_hash[launcher_label].tbm_doctrine      = tbm_doctrine        unless tbm_doctrine.nil?
          launcher_hash[launcher_label].abt_doctrine      = abt_doctrine        unless abt_doctrine.nil?
          
          launcher_hash[launcher_label].standard_interceptor_velocity = interceptor_data['mp_interceptor_rec'].velocity.to_f

          launcher_hash[launcher_label].tracking_radar = battery_sensor

          launcher_hash[launcher_label].reset

        # end ## end of if k.downcase.include?(battery_type)

      # end ## end of $battery_types.each do |battery_type|

    end ## end of launcher_config.each_pair do |lc_key, lc_value|

  end ## end of $idp_batteries.each_pair do |k,v|

  pp launcher_hash if $debug

  FARM = launcher_hash
  
  ISE::Log.debug "Total Number of Launcher Instances: #{launcher_hash.length}"

  
  battery_hash = Hash.new
  
  TOC = Toc.new('tac_ops', 'UAE')

  FARM.each_pair do |k,v|
    TOC.attach_launcher(v)
    battery_label = v.battery_label
    if battery_hash.include?(battery_label)
      battery_hash[battery_label].rounds_available += v.rounds_available
    else
      battery_hash[battery_label]                   = OpenStruct.new
      battery_hash[battery_label].rounds_available  = v.rounds_available
    end
  end


  BATTERY_FARM  = battery_hash

  ISE::Log.debug "Total Number of Battery  Instances: #{battery_hash.length}"

  ###############################################################
  ## Get User's auto-engage selections from the selected scenario
  s = MpScenario.selected[0]

  # command line parameters trump user's selection
  $OPTIONS[:auto_engage_tbm] = s.auto_engage_tbm  if  $OPTIONS[:auto_engage_tbm].nil?
  $OPTIONS[:auto_engage_abt] = s.auto_engage_abt  if  $OPTIONS[:auto_engage_abt].nil?
 



  unless $do_not_garbage_collect

    ###############################################################
    # reclaim some memory
    $idp_scenario       = nil
    $idp_batteries      = nil
    $idp_defended_aois  = nil
    $idp_launch_aois    = nil
    $idp_weapon_systems = nil
    
    GC.start
  
  end

end ## module BatteryFarmModel

# end of battery_farm_model.rb
#########################################################################
