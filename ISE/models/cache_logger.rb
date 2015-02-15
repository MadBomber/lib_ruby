#!/usr/bin/env ruby
#############################################################
###
##  File: cache_logger.rb
##  Desc: Logs information from SharedMemCache to the database
##
##  TODO:  Find out if ActiveRecord can save an array to a table
##  TODO:  Log missing events
##  TODO:  Create hashes to pass data between logging functions
#

require 'eventmachine'

require 'aadse_utilities'

write_pid_file_for __FILE__

require 'aadse_database'
require 'SimStatus'
require 'Target'
require 'Aircraft'
require 'Missile'
require 'Interceptor'
require 'Launcher'
require 'DefendedArea'

$debug   = false
$verbose = true


class CacheLogger

  attr_accessor :run_status_ids

  include Failsafe_Cache_Extraction

  ##############################################################
  ##   INITIALIZATION
  ##############################################################


  ## initialize variables and log a priori data
  ##############
  def initialize
    init_hashes
    log_a_priori_data

    return nil
  end ## def initialize


  ###############
  def init_hashes
    @defendedarea_ids = {}

    init_run_status_hash
    init_table_hashes
    init_object_hashes
    init_battery_hashes
    init_launcher_hashes
    init_interceptor_hashes
    init_threat_hashes

    return nil
  end ## def init_hashes


  ########################
  def init_run_status_hash
    @run_status_ids  = {
      'initializing' => 0,
      'loaded'       => 1,
      'running'      => 2,
      'paused'       => 3
    }

    return nil
  end ## def init_run_status_hash


  ## Class type to database table translation
  ####################
  def init_table_hashes
    @object_tables   = {
      'interceptor'  => RuntimeInterceptor,
      'launcher'     => RuntimeLauncher,
      'battery'      => RuntimeBattery,      # battery class doesn't exist yet
      'defendedarea' => RuntimeDefendedArea,
      'aircraft'     => RuntimeThreat,
      'missile'      => RuntimeThreat,
      'target'       => RuntimeThreat,
      'threat'       => RuntimeThreat
    }

    @event_tables   = {
      'interceptor' => RuntimeInterceptorEvent,
      'launcher'    => RuntimeLauncherEvent,
      'battery'     => RuntimeBatteryEvent,
      'aircraft'    => RuntimeThreatEvent,
      'missile'     => RuntimeThreatEvent,
      'target'      => RuntimeThreatEvent,
      'threat'      => RuntimeThreatEvent
    }

    @position_tables = {
      'interceptor'  => RuntimeInterceptorPosition,
      'aircraft'     => RuntimeThreatPosition,
      'missile'      => RuntimeThreatPosition,
      'target'       => RuntimeThreatPosition,
      'threat'       => RuntimeThreatPosition
    }

    @table_type = {
      'object'   => @object_tables,
      'event'    => @event_tables,
      'position' => @position_tables
    }

    return nil
  end ## def init_table_hashes


  ## Object types &  IDs
  ##############
  def init_object_hashes
    @object_type        = {
      'interceptor'     => 'interceptor',
      'launcher'        => 'launcher',
      'battery'         => 'battery',
      'aircraft'        => 'threat', ## probably shouldn't be a threat
      'hostileaircraft' => 'threat',
      'target'          => 'threat',
      'threat'          => 'threat',
      'defendedarea'    => 'defendedarea'
    }

    @object_type_ids = {
      'interceptor'  => 1,
      'launcher'     => 2,
      'battery'      => 3,
      'threat'       => 4,
      'defendedarea' => 5
    }

    return nil
  end ## def init_object_hashes


  #######################
  def init_battery_hashes
    @battery_ids = {}

    @battery_class_ids = {
      'pac3'           => 1,
      'pac3launcher'   => 1,
      'gemt'           => 1,
      'gemtlauncher'   => 1,
      'thaad'          => 2,
      'thaadlauncher'  => 2
    }

    @battery_event_ids             = {
      'engage command received'    => 10,
      'engagement_failure'         => 11,
      're-engage command received' => 12,
      'hit'                        => 15,
      'miss'                       => 16,
      'engagement_cancelled'       => 17,
      'interceptor_terminated'     => 18
    }

    @launch_failed_details = {
      'out of time'        => 4,
      'weapon hold'        => 5,
      'mis-fire'           => 6,
      'out_of_service'     => 7
    }

    return nil
  end ## def init_battery_hashes


  ########################
  def init_launcher_hashes
    @launcher_ids = {}

    @launcher_class_ids = {
      'pac3'           => 1,
      'pac3launcher'   => 1,
      'gemt'           => 2,
      'gemtlauncher'   => 2,
      'thaad'          => 3,
      'thaadlauncher'  => 3
    }

    @launcher_event_ids = {
      'launched'        =>  5,
      'ez breached'     =>  6,
      'fcs breached'    => 13
    }

    return nil
  end ## def init_launcher_hashes


  ###########################
  def init_interceptor_hashes
    @interceptors = {}
    ## contents: {
    #    'interceptor_name' => {
    #       'id' => interceptor_id,
    #       'birth' => birth_id,
    #       'death' => death_id
    #    }
    #  }


    @interceptor_class_ids = {
      'pac3'              => 1,
      'gemt'              => 2,
      'thaad'             => 3,
    }

    @interceptor_event_ids     = {
      'hit'                    =>  7,
      'launched'               =>  8,
      'interceptor_terminated' =>  9,
      'miss'                   => 14
    }

    return nil
  end ## def init_interceptor_hashes


  ######################
  def init_threat_hashes
    @threat_ids = {}

    ## TODO: not implemented yet
    @threats = {}
    ## contents: {
    #    'threat_name' => {
    #       'id' => threat_id,
    #       'poo calculated' => poo_id,
    #       'poi calculated' => poi_id,
    #       'found track'    => fnd_id,
    #       'impacted        => imp_id
    #    }
    #  }

    @threat_class_ids    = {
      'cm'              => 1,
      'srbm'            => 2,
      'mrbm'            => 3,
      'lrbm'            => 4,
      'icbm'            => 4,
      'hostileaircraft' => 5,
      'mig'             => 5,
      'mig23'           => 5,
      'mig26'           => 5,
      'helicopter'      => 5,
      'uav'             => 6,
    }

    @threat_event_ids  = {
      'poo calculated' =>  1,
      'poi calculated' =>  2,
      'lost track'     =>  3,
      'found track'    =>  4,
      'impacted'       => 19
    }

    @lost_track_details = {
      'lost'            => 1,
      'impacted'        => 2,
      'intercepted'     => 3
    }

    return nil
  end ## def init_threat_hashes




  ##############################################################
  ##   A PRIORI DATA LOGGING
  ##############################################################


  #####################
  def log_a_priori_data
    printf('Logging a priori data')
    puts if $debug
    
    functions = [:log_run, :log_all_defended_areas, :log_all_batteries, :log_all_launchers, :log_all_threats]

    functions.each do |function|
      unless $debug
        method(function).call
        printf('.')
      else
        function_time = time_this(function)
        log_debug("Execution time of #{function.to_s}: #{function_time} seconds")
      end
    end

    puts('.') unless $debug

    return nil
  end ## def log_a_priori_data


  ## log the a priori information describing this run
  ###########
  def log_run
    @run_data = RuntimeEntry.new

    @run_data.GUID          = UUIDTools::UUID.random_create.to_s
    @run_data.start_time    = get_from_cache('start_time')
    @run_data.run_status_id = SharedMemCache.get('sim_status').to_s
    @run_data.scenario_id   = get_from_cache('FP:scenario_id')

    @run_data.save

    ## set the current run GUID in the cache
    SharedMemCache.add('current_run', 'Contains the GUID and ID for the current run of cache_logger.')
    SharedMemCache.set('current_run', [@run_data.GUID, @run_data.id])

    return nil
  end ## def log_run


  ## log all defended areas in the cache that are new
  ######################
  def log_all_defended_areas

    log_objects(get_from_cache('defended_area_names'))

    return nil
  end ## def log_all_defended_areas


  ## log all batteries that are new
  ## batteries are found in launchers in the cache
  ##############################
  def log_all_batteries
    launcher_names = get_from_cache('launcher_names')
    battery_names = []

    launcher_names.each do |launcher_name|
      battery_names << get_from_cache(launcher_name, :battery_name)
    end

    log_objects(battery_names)

    return nil
  end ## def log_all_batteries


  ## log all launchers in the cache that are new
  #################
  def log_all_launchers
    log_objects(get_from_cache('launcher_names'))

    return nil
  end ## def log_all_launchers


  ## log all threats in the cache that are new
  #################
  def log_all_threats
    threat_names = get_all_threat_names

    log_objects(threat_names)

    return nil
  end ## def log_all_threats

  ## log all threat positions for a particular threat
  #####################################
  def log_all_threat_positions
    threat_names = get_all_threat_names

    threat_names.each do |threat_name|
      time = @run_data.start_time # time of position list; starts at scenario start time
      pos_list = get_from_cache('Position:' + threat_name)

      ## NOTE: pos_list contains an array of positions computed a priori
      ##       they are at one second intervals starting at the sim start time

      if pos_list
        ## log all threat positions
        pos_list.each do |position|
          log_object_position(threat_name, position, time) unless position.nil?

          time += 1
        end ## pos_list.each do |position|
      else ## unless pos_list
        log_debug("Cache item: 'Position:#{threat_name}' is nil.")
      end ## if pos_list
    end ## threat_names.each do |threat_name|

    return nil
  end ## def log_all_threat_positions threat_id, pos_list


  def get_all_threat_names
    threat_names = get_from_cache('missile_names')
    threat_names.concat(get_from_cache('aircraft_names'))

    threat_names.delete_if {|threat_name| threat_name.is_blue_force?}

    return threat_names
  end ## def get_all_threat_names




  ##############################################################
  ##   RUNTIME DATA LOGGING
  ##############################################################


  ## log new data as it appears during the run
  ####################
  def log_runtime_data
    log_sim_status

    if sim_running?
      printf('Logging runtime data') if $verbose
      puts if $debug and $verbose

      active_functions = [:log_threat_events, :log_interceptors, :check_events]

      active_functions.each do |function|
        unless $debug
          method(function).call
          printf('.') if $verbose
        else
          puts("Logging #{function.to_s}")
          function_time = time_this(function)
          puts("Execution time of #{function.to_s}: #{function_time} seconds")
        end
      end

      puts #unless $debug
    end ## if sim_running?

    return nil
  end ## def log_runtime_data


  ## log run status id if it changes
  ## log most recent valid stop time
  ##################
  def log_sim_status
    need_to_save = false

    if sim_running? or sim_paused? or @run_data.stop_time.nil?
      @run_data.stop_time = get_from_cache('sim_time')
      need_to_save = true
    end

    status_id = @run_status_ids[get_from_cache('sim_status').to_s]

    if status_id != @run_data.run_status_id
      @run_data.run_status_id = status_id
      need_to_save = true
    end

    @run_data.save if need_to_save

    return nil
  end ## def log_sim_status


  ## get new events that are logged to the cache
  ################
  def check_events
    ## check battery events
    get_engagement_failure
    get_engagement_cancellation

    return nil
  end ## def check_events


  ##############################################################
  ##   BATTERIES
  ##############################################################


  ## log new battery event
  ## battery events are triggered by interceptor events
  ###################################################
  def log_battery_event(interceptor_name, event_name)
    launcher_name = get_from_cache(interceptor_name, :launcher_name)
    threat_name   = get_from_cache(interceptor_name, :target_name)
    battery_name  = get_from_cache(launcher_name,    :battery_name)

    ## get custom battery event data
    case event_name
    when 'engage command received'
      return nil ## TODO: find a way to get this event
      time = get_from_cache(interceptor_name, :launch_time)
      lla  = get_from_cache(interceptor_name, :launch_lla)
      event_detail = nil

    when 'engagement failed'
      return nil ## FIXME: currently in log_runtime_data method
      get_engagement_failure

    when 're-engage command received'
      return nil ## TODO: find a way to get this event
      event_detail = nil

    when 'hit', 'miss'
      time = get_from_cache(interceptor_name, :pip_time)
      lla  = get_from_cache(interceptor_name, :impact_lla)
      event_detail = nil
      
      threat_hash = get_object_id_hash(threat_name)

      ## only want one hit or miss per engagement; hit overrides miss
      case event_name
      when 'hit'
        miss_entry = find_event_entry(battery_name, 'miss', threat_hash)

        unless miss_entry.nil?
          log_debug("#{battery_name} had previously missed #{threat_name}, we hit it now so remove miss.")
          delete_event_entry(battery_name, 'miss', threat_hash)
        end

      when 'miss'
        hit_entry = find_event_entry(battery_name, 'hit', threat_hash)
        
        unless hit_entry.nil?
          log_debug("#{battery_name} already hit #{threat_name}, we don't care that we missed.")
          return nil
        end

      end

    when 'cancelled'
      return nil ## FIXME: currently in log_runtime_data method
      get_engagement_cancellation

    when 'terminated'
      return nil ## FIXME: no longer logged
      get_interceptor_termination

    else
      fatal_error "Battery #{battery_name}'s had an unexpected event request: #{event_name}"
    end ## case event_name


    log_object_event(battery_name, event_name, event_detail, lla, time, threat_name)

    return nil
  end ## def log_battery_event(interceptor_name, event_name)


  ## Checks engagement_failure for new events
  ## Logs new events if they exist
  ##########################
  def get_engagement_failure

    engagement_failure = $engagement_failure.pop

    unless engagement_failure.nil?
      object_name  = engagement_failure['object_name']
      object_type  = get_object_type(object_name)
      event_name   = engagement_failure['event_name'].downcase
      time         = engagement_failure['sim_time']
      event_desc   = engagement_failure['event_desc'].to_s

      if event_desc.include?('second round not available')
        event_detail = @launch_failed_details['out_of_service']
      else
        event_detail = @launch_failed_details[event_desc]
      end


      ## object_type could be an interceptor or a launcher
      ## get data in different ways depending on object type
      case object_type
      when 'interceptor'
        launcher_name = get_from_cache(object_name,   :launcher_name)
        battery_name  = get_from_cache(launcher_name, :battery_name)
        threat_name   = get_from_cache(object_name,   :target_name)

      when 'launcher'
        launcher_name = object_name
        battery_name  = get_from_cache(launcher_name, :battery_name)
        threat_name   = nil # FIXME: cannot retrieve target_name with given information

      else
        fatal_error "Object: #{object_name} of type: #{object_type} was unexpected for #{event_name}."
      end

      lla = get_from_cache(launcher_name, :lla)

      log_object_event(battery_name, event_name, event_detail, lla, time, threat_name)
    end

    return nil
  end ## def get_engagement_failure


  ## Checks engagement_cancelled for new events
  ## Logs new events if they exist
  ###############################
  def get_engagement_cancellation
    engagement_cancellation = $engagement_cancelled.pop

    unless engagement_cancellation.nil?
      launcher_name    = engagement_cancellation['object_name']
      battery_name     = get_from_cache(launcher_name, :battery_name)
      interceptor_name = engagement_cancellation['event_desc']
      threat_name      = get_from_cache(interceptor_name, :target_name)
      event_name       = engagement_cancellation['event_name'].downcase
      event_detail     = nil
      time             = engagement_cancellation['sim_time']
      lla              = get_from_cache(launcher_name, :lla)

      log_object_event(battery_name, event_name, event_detail, lla, time, threat_name)
    end

    return nil
  end ## def get_engagement_cancellation


  
  ##############################################################
  ##   LAUNCHERS
  ##############################################################


  ## log new launcher event
  ## launcher events are triggered by interceptor events
  ####################################################
  def log_launcher_event(interceptor_name, event_name)
    launcher_name = get_from_cache(interceptor_name, :launcher_name)
    threat_name   = get_from_cache(interceptor_name, :target_name)
    event_detail  = nil

    ## get custom launcher event data
    case event_name
    when 'launched'
      time = get_from_cache(interceptor_name, :launch_time)
      lla  = get_from_cache(interceptor_name, :launch_lla)

    when 'ez breached'
      return nil
      # TODO: find a way to get this event

    when 'fcs breached'
      return nil
      # TODO: find a way to get this event

    else
      fatal_error "#{launcher_name} had an unexpected event request: #{event_name}."
    end ## case event_name

    return log_object_event(launcher_name, event_name, event_detail, lla, time, threat_name)
  end ## def log_launcher_event(interceptor_name, event_name)


  
  ##############################################################
  ##   INTERCEPTORS
  ##############################################################


  ####################
  def log_interceptors
    get_new_interceptors

    @interceptors.each_pair do |interceptor, categories|
      categories.each_pair do |category, value|
        if value == nil
          case category
          when 'id'
            log_debug("Logging new interceptor: #{interceptor}")
            @interceptors[interceptor][category] = log_object(interceptor)

          when 'birth'
            @interceptors[interceptor][category] = log_interceptor_event(interceptor, 'launched')

          when 'death'
            engagement_result = get_from_cache(interceptor, :engagement_result).to_s
            @interceptors[interceptor][category] = log_interceptor_event(interceptor, engagement_result)

          else
            fatal_error("Unexpected category: #{category}.")
          end ## case category
        end ## if value == nil
      end ## categories.each_pair do |category, value|

      ## FIXME: should be in engagement results
      log_interceptor_event(interceptor, 'interceptor_terminated')
    end ## @interceptors.each_pair do |interceptor, categories|
  end ## def log_interceptors

  
  ########################
  def get_new_interceptors
    ## get new interceptor
    interceptor_names = check_cache_for 'interceptor_names'
    
    interceptor_names.each do |interceptor_name|
      unless @interceptors.include?(interceptor_name)
        @interceptors[interceptor_name] = {
          'id' => nil,
          'birth' => nil,
          'death' => nil
        }
      end ## unless @interceptors.include?(interceptor_name)
    end ## interceptor_names.each do |interceptor_name|
    
    return nil
  end ## def get_new_interceptors


  ##############################################
  def log_interceptor_position(interceptor_name)
    time = get_from_cache 'sim_time'
    lla  = get_from_cache interceptor_name, :lla

    log_object_position(interceptor_name, lla, time)
  end ## def log_interceptor_position(interceptor_name)


  #######################################################
  def log_interceptor_event(interceptor_name, event_name)
    current_sim_time  = get_from_cache('sim_time')
    threat_name = get_from_cache(interceptor_name, :target_name)
    
    ## get custom interceptor event data
    case event_name
    when 'launched'
      time = check_cache_for(interceptor_name, :launch_time)

      return nil if time.nil?

      return nil if time < current_sim_time

      log_launcher_event(interceptor_name, event_name)

      lla  = check_cache_for(interceptor_name, :launch_lla)

      return nil if lla.nil?

    when 'hit', 'miss'
      engagement_result = check_cache_for(interceptor_name, :engagement_result)

      return nil if engagement_result.nil?
      
      ## return if result different than current event trying to be logged
      return nil if engagement_result.to_s != event_name

      time = get_from_cache(interceptor_name, :pip_time)

      return nil if time.nil?
      
      return nil if time < current_sim_time

      lla  = get_from_cache(interceptor_name, :impact_lla)

      return nil if lla.nil?
        
      log_battery_event(interceptor_name, event_name)

      delete_position_entries_after(threat_name, time) if engagement_result == :hit
      
    when 'interceptor_terminated'
      get_interceptor_termination
      return nil

    else
      fatal_error "Interceptor: #{interceptor_name} had an unexpected event request: #{event_name}."
    end ## case type.name
    
    event_detail = nil

    return log_object_event(interceptor_name, event_name, event_detail, lla, time, threat_name)
  end ## def log_interceptor_event(interceptor_name, event_name)


  ## Checks interceptor_terminated for new events
  ## Logs new events if they exist
  ##############################
  def get_interceptor_termination
    engagement_termination = $interceptor_terminated.pop

    unless engagement_termination.nil?
      interceptor_name = engagement_termination['object_name']
      threat_name      = get_from_cache(interceptor_name, :target_name)
      old_result       = get_from_cache(interceptor_name, :engagement_result)
      event_name       = engagement_termination['event_name'].downcase
      event_detail     = nil
      lla              = get_from_cache(interceptor_name, :impact_lla)
      time             = engagement_termination['sim_time']

      delete_event_entry(interceptor_name, old_result)

      @interceptors[interceptor_name]['death'] = log_object_event(interceptor_name, event_name, event_detail, lla, time, threat_name)
    end

    return nil
  end ## def get_interceptor_termination




  ##############################################################
  ##   THREATS
  ##############################################################


  ## log all threat events for threats as they occur
  ###############
  def log_threat_events
    @threat_ids.each_key do |threat_name|
      log_threat_event(threat_name, 'poo calculated')
      log_threat_event(threat_name, 'found track')
      log_threat_event(threat_name, 'poi calculated')
      log_threat_event(threat_name, 'lost track')
      log_threat_event(threat_name, 'impacted')
    end

    return nil
  end ## def log_threat_events


  ## log a threat event for a particular threat
  #############################################
  def log_threat_event(threat_name, event_name)
    tolerance = [3, 20]

    ## get custom threat event data
    case event_name
    when 'poo calculated' then
      time = get_from_cache('sim_time')
      lla  = check_cache_for(threat_name, :launch_lla)
      event_detail = nil

      return nil if lla.nil?

    when 'poi calculated' then
      time = get_from_cache('sim_time')
      lla  = check_cache_for(threat_name, :impact_lla)
      threatened_defended_area = check_cache_for(threat_name, :threat_to)

      return nil if threatened_defended_area.nil? or lla.nil?

      event_detail = @defendedarea_ids[threatened_defended_area]

    when 'impacted' then
      return nil if threat_intercepted?(threat_name)

      sim_time = get_from_cache('sim_time')
      time = check_cache_for(threat_name, :impact_time)
      lla  = check_cache_for(threat_name, :impact_lla)
      threatened_defended_area = check_cache_for(threat_name, :threat_to)

      return nil if time.nil? or lla.nil?

      return nil if sim_time < time - tolerance[0]

      if threatened_defended_area.nil?
        log_debug "Threat: #{threat_name} had no valid threatened defeneded area."

        if time > sim_time + tolerance[1]
          log_debug "Recording impact anyway, just couldn't get a defended area."
          event_detail = nil
        else
          return nil
        end
      else ## unless threatened_defended_area.nil?
        event_detail = @defendedarea_ids[threatened_defended_area]
      end ## if threatened_defended_area.nil?

    when 'lost track' then
      time = get_detected_time(threat_name, :last)

      return nil if time.nil?

      ## don't log unless the track is pretty old
      return nil unless time_old?(time)

      lla = get_threat_lla_at_time(threat_name, time)

      ## if lla doesn't exist, get last time it exists
      if lla.nil?
        time = get_prev_time_threat_existed(threat_name, get_from_cache('end_time'))
        lla = get_threat_lla_at_time(threat_name, time)

        if lla.nil?
          log_debug("Threat: #{threat_name} doesn't exist at: #{time}, can't be lost yet.")
          return nil
        end
      end

      interceptor_name = get_threat_interceptor(threat_name)
      impact_time      = get_from_cache(threat_name, :impact_time)
      event_detail     = nil

      if interceptor_name.nil?
        if impact_time >= time - tolerance[0]
          event_detail = @lost_track_details['impacted']
        end
      else
        intercept_time   = get_from_cache(interceptor_name, :pip_time)

        if intercept_time >=  time - tolerance[0]
          event_detail = @lost_track_details['intercepted']
        end
      end

      event_detail = @lost_track_details['lost'] if event_detail.nil?
      

    when 'found track' then
      time = get_detected_time(threat_name, :first)
      return nil if time.nil?
      lla = get_threat_lla_at_time(threat_name, time)

      ## if lla doesn't exist, get first time it exists
      if lla.nil?
        time = get_next_time_threat_exists(threat_name, @run_data.start_time)
        lla = get_threat_lla_at_time(threat_name, time)

        if lla.nil?
          log_debug("Threat: #{threat_name} doesn't exist at: #{found_time}, must already be gone.")
          return nil
        end
      end
      
      event_detail = nil

    else
      fatal_error "Threat: #{threat_name} had an unexpected event request: #{event_name}"
    end ## case event_name

    log_object_event(threat_name, event_name, event_detail, lla, time)

    return nil
  end ## def log_threat_event(threat_name, event_name)


  ## return the earliest or latest detection time for a threat
  ####################################################
  def get_detected_time(threat_name, time_of_interest)
    time_offset = nil

    ## get the relevant comparitor
    case time_of_interest
    when :first
      comparitor = :<

    when :last
      comparitor = :>

    else
      fatal_error "Threat: #{threat_name} had an unexpected time of interest: #{time_of_interest}"
    end ## case time_of_interest

    detectors = check_cache_for(threat_name, :detected_by)

    detectors.each_value do |time_range|
      time = time_range.method(time_of_interest).call

      ## get earliest or latest detection time
      time_offset = time if time_offset.nil? or time.method(comparitor).call time_offset
    end ## detectors.each_value do |time_range|

    return time_offset
  end ## def get_detected_time(threat_name, time_of_interest)


  ## check if the time is much older than the current sim time
  ###################
  def time_old?(time)
    fudge_time = 10

    return (time + fudge_time) < get_from_cache('sim_time')
  end ## def time_old?(time)


  ## get the position of a threat at a particular time
  #############################################
  def get_threat_lla_at_time(threat_name, time)
    relative_time = (time - @run_data.start_time).round
    pos_list      = get_from_cache('Position:' + threat_name)

    return pos_list[relative_time]
  end ## def get_threat_lla_at_time(threat_name, time)


  ##################################################
  def get_next_time_threat_exists(threat_name, time)
    start_time = @run_data.start_time
    pos_list      = get_from_cache('Position:' + threat_name)
    relative_time = (time - start_time).round
    stop_time = get_from_cache('pc_time_limit')

    (relative_time..stop_time).each do |a_time|
      return (start_time + a_time) unless pos_list[a_time].nil?
    end

    return nil
  end ## def get_next_time_threat_exists(threat_name, time)


  ###################################################
  def get_prev_time_threat_existed(threat_name, time)
    start_time = @run_data.start_time
    pos_list      = get_from_cache('Position:' + threat_name)
    relative_time = (time - start_time).round

    a_time = relative_time

    while a_time >= 0
      return (start_time + a_time) unless pos_list[a_time].nil?

      a_time -= 1
    end

    return nil
  end ## def get_prev_time_threat_existed(threat_name, time)


  ###############################################
  def get_threat_lla_near_time(threat_name, time)
    prev_time = get_prev_time_threat_exists(threat_name, time)
    next_time = get_next_time_threat_exists(threat_name, time)

    if prev_time.nil? and next_time.nil?
      fatal_error("No valid positions for: #{threat_name}")
    elsif prev_time.nil?
      found_time = next_time
    elsif next_time.nil?
      found_time = prev_time
    else
      if (time - prev_time) > (next_time - time)
        found_time = next_time
      else
        found_time = prev_time
      end
    end

    return get_threat_lla_at_time(threat_name, found_time)
  end ## def get_threat_lla_near_time(threat_name, time)


  ####################################
  def threat_intercepted?(threat_name)
    engaged_by = check_cache_for(threat_name, :engaged_by)

    engaged_by.each_key do |interceptor_name|
      eng_res = get_from_cache(interceptor_name, :engagement_result)
      return true if eng_res == :hit
    end

    return false ## no hits, so not intercepted
  end ## def threat_intercepted?(threat_name)


  #######################################
  def get_threat_interceptor(threat_name)
    if threat_intercepted?(threat_name)
      engaged_by = get_from_cache(threat_name, :engaged_by)

      earliest_time = get_from_cache(threat_name, :impact_time)
      threat_interceptor = nil

      engaged_by.each_key do |interceptor_name|
        eng_res = get_from_cache(interceptor_name, :engagement_result)

        if eng_res == :hit
          intercept_time = get_from_cache(interceptor_name, :pip_time)

          if intercept_time < earliest_time
            earliest_time = intercept_time
            threat_interceptor = interceptor_name
          end
        end
      end

      return threat_interceptor
    else ## unless threat_intercepted?(threat_name)
      return nil
    end ## if threat_intercepted?(threat_name)
  end ## def get_threat_interceptor(threat_name)


  ########################################################
  ##   GENERAL LOGGING METHODS
  ########################################################


  ###########################
  def log_object(object_name)

    existing_object = find_object_entry(object_name)

    if existing_object.nil?
      object_type = get_object_type(object_name)
      table = @object_tables[object_type]

      log_object = table.new

      log_object.name = object_name
      log_object.GUID = @run_data.GUID

      log_object_specific_data(log_object)

      log_object.save

      return log_object.id
    else ## unless existing_object.nil?
      return existing_object.id
    end ## if existing_object.nil?
  end ## def log_object(log_object, object_name, position = nil)



  #########################
  def log_objects(object_names)
    object_type = get_object_type(object_names[0])
    object_ids = instance_variable_get("@#{object_type}_ids")

    object_names.each do |object_name|
      unless object_ids.include?(object_name)
        object_ids[object_name] = log_object(object_name)
      end
    end

    return nil
  end ## def log_objects(object_names)

  
  ########################################
  def log_object_specific_data(log_object)
    object_name = log_object.name
    object_type = get_object_type(object_name)

    case object_type
    when 'defendedarea'
      radius   = check_cache_for(object_name, :range)
      
      unless radius.nil?
        log_object.radius = radius.round
      else
        log_error("Radius was nil for defended area: #{object_name}")
      end
      
    when 'battery'
      log_object.battery_id = get_class_id(object_name)
      
    when 'launcher'
      battery_name = get_from_cache(object_name, :battery_name)

      log_object.launcher_id        = get_class_id(object_name)
      log_object.runtime_battery_id = get_object_id(battery_name)
      
    when 'interceptor'
      launcher_name = get_from_cache(object_name, :launcher_name)
      
      log_object.interceptor_id      = get_class_id(object_name)
      log_object.runtime_launcher_id = get_object_id(launcher_name)
      
    when 'threat'
      log_object.threat_type_id = get_class_id(object_name)
      
    else
      fatal_error("Unexpected object type for: #{object_name}.")
    end ## case object_type

    if log_object.respond_to?('latitude')
      position = get_from_cache(object_name, :lla)

      log_object = store_general_position(log_object, position)
    end

    return log_object
  end ## def log_object_specific_data(log_object)


  ##############################################################################
  def log_object_event(object_name, event_name, event_detail, position, time, threat_name = nil)
    if threat_name.nil?
      existing_event = find_event_entry(object_name, event_name)
    else
      existing_event = find_event_entry(object_name, event_name, get_object_id_hash(threat_name))
    end

    object_type = get_object_type(object_name)

    if existing_event.nil?
      log_debug("#{event_name} occurred for #{object_type}: #{object_name}.")
      log_event = get_object_table('event', object_name).new

      log_event = store_object_position(log_event, object_name, position, time)
      log_event.runtime_event_id = get_event_id(object_name, event_name)
      log_event.event_detail     = event_detail

      unless object_type == 'threat'
        log_event.runtime_threat_id = get_object_id(threat_name)
      end

      log_event.save

      return log_event.id
    else ## unless existing_event.nil?
      return existing_event.id
    end ## if existing_event.nil?
  end ## def log_object_event(object_name, event_name, event_detail, position, time, threat_name = nil)


  ####################################################
  def log_object_position(object_name, position, time)
    return nil if time.nil? or position.nil?

    existing_position = find_position_entry(object_name, time)

    if existing_position.nil?
      log_position = get_object_table('position', object_name).new

      log_position = store_object_position(log_position, object_name, position, time)

      log_position.save

      return log_position.id
    else ## unless existing_position.nil?
      return existing_position.id
    end ## if existing_position.nil?
  end ## def log_object_position(object_name, position, time)



  ####################################################################
  def store_object_position(log_position, object_name, position, time)
    object_type = get_object_type(object_name)
    object_id   = get_object_id(object_name)

    ## store object id
    log_position.method_missing("runtime_#{object_type}_id=".to_sym, object_id)

    log_position.relative_time = (time - @run_data.start_time).round

    return store_general_position(log_position, position)
  end ## def store_object_position(log_position, object_name, position, time)


  ######################################
  def store_general_position(log_position, position)
    log_position.latitude      = position.lat
    log_position.longitude     = position.lng
    log_position.altitude      = position.alt

    return log_position
  end ## def store_general_position(log_position, position)


  ########################################################
  ##   FIND LOGGED ENTRIES
  ########################################################


  #########################################################
  def find_object_entry(object_name, other_conditions = {})
    return find_entry('object', object_name, get_guid_hash + other_conditions)
  end ## def find_object_entry(object_name, other_conditions = {})


  ####################################################################
  def find_event_entry(object_name, event_name, other_conditions = {})
    event_hash = get_event_id_hash(object_name, event_name)

    entry = find_entry('event', object_name, event_hash + other_conditions)

    return entry
  end ## def find_event_entry(object_name, event_name, other_conditions = {})


  #################################################################
  def find_position_entry(object_name, time, other_conditions = {})
    time_hash = get_relative_time_hash(time)

    return find_entry('position', object_name, time_hash + other_conditions)
  end ## def find_position_entry(object_name, time, other_conditions = {})


  ##########################################################################
  def find_position_entries_before(object_name, time, other_conditions = {})
    return find_time_conditional_entries(object_name, time, '>', other_conditions)
  end ## def find_position_entries_before(object_name, time, other_conditions = {})


  #########################################################################
  def find_position_entries_after(object_name, time, other_conditions = {})
    return find_time_conditional_entries(object_name, time, '>', other_conditions)
  end ## def find_position_entries_after(object_name, time, other_conditions = {})


  ################################################################################################
  def find_time_conditional_position_entries(object_name, time, comparitor, other_conditions = {})
    time_hash = get_relative_time_hash(time, comparitor)

    return find_entries('position', object_name, time_hash + other_conditions)
  end ## def find_time_conditional_position_entries(object_name, time, comparitor, other_conditions = {})


  ## find an entry based on the object name and any other conditions
  ##############################################################
  def find_entry(table_type, object_name, other_conditions = {})
    conditions = other_conditions
    if table_type == 'object'
      conditions += get_self_id_hash(object_name)
    else
      conditions += get_object_id_hash(object_name)
    end

    table = get_object_table(table_type, object_name)

    conditions.each_value do |value|
      if value == nil
        
        return nil
      end
    end

    return table.find(:first, :conditions => get_condition_string(conditions))
  end ## def find_entry(table_type, object_name, other_conditions = {})


  ## find all entry based on the object name and any other conditions
  ################################################################
  def find_entries(table_type, object_name, other_conditions = {})
    conditions = get_self_id_hash(object_name) + other_conditions
    table = get_object_table(table_type, object_name)

    conditions.each_value do |value|
      return nil if value == nil
    end

    return table.find(:all, :conditions => get_condition_string(conditions))
  end ## def find_entries(table_type, object_name, other_conditions = {})




  ########################################################
  ##   DELETE LOGGED ENTRIES
  ########################################################


  ###########################################################
  def delete_object_entry(object_name, other_conditions = {})
    object_entry = find_object_entry(object_name, other_conditions)
    object_entry.delete unless object_entry.nil?

    return nil
  end ## def delete_object_entry(object_name, other_conditions = {})


  ######################################################################
  def delete_event_entry(object_name, event_name, other_conditions = {})
    event_entry = find_event_entry(object_name, event_name, other_conditions)
    event_entry.delete unless event_entry.nil?

    return nil
  end ## def delete_event_entry(object_name, event_name, other_conditions = {})


  #########################################################################
  def delete_event_entries(object_name, event_names, other_conditions = {})
    event_names = Array(event_names)

    event_names.each do |event_name|
      delete_entries('event', object_name, other_conditions + get_event_id_hash(object_name, event_name))
    end

    return nil
  end ## def delete_event_entries(object_name, event_names, other_conditions = {})


  ###################################################################
  def delete_position_entry(object_name, time, other_conditions = {})
    time_hash = get_relative_time_hash(time)

    delete_entry('position', object_name, time_hash + other_conditions)

    return nil
  end ## def delete_position_entry(object_name, time, other_conditions = {})


  ###########################################################################
  def delete_position_entries_after(object_name, time, other_conditions = {})
    delete_time_conditional_position_entries(object_name, time, '>', other_conditions)

    return nil
  end ## def delete_position_entries_after(object_name, time, other_conditions = {})


  ############################################################################
  def delete_position_entries_before(object_name, time, other_conditions = {})
    delete_time_conditional_position_entries(object_name, time, '<', other_conditions)

    return nil
  end ## def delete_position_entries_before(object_name, time, other_conditions = {})


  ##################################################################################################
  def delete_time_conditional_position_entries(object_name, time, comparitor, other_conditions = {})
    time_hash = get_relative_time_hash(time, comparitor)

    delete_entries('position', object_name, time_hash + other_conditions)

    return nil
  end ## def delete_time_conditional_position_entries(object_name, time, comparitor, other_conditions = {})


  ################################################################
  def delete_entry(table_type, object_name, other_conditions = {})
    entry = find_entry(table_type, object_name, other_conditions)
    entry.delete unless entry.nil?

    return nil
  end ## def delete_entry(table_type, object_name, other_conditions = {})


  ##################################################################
  def delete_entries(table_type, object_name, other_conditions = {})
    object_hash = get_self_id_hash(object_name)
    table       = get_object_table(table_type, object_name)

    conditions = object_hash + other_conditions

    conditions.each_value do |value|
      return nil if value == nil
    end

    table.delete_all(get_condition_string(conditions))

    return nil
  end ## def delete_entries(table_type, object_name, other_conditions = {})




  ########################################################
  ##   GET OBJECT INFORMATION
  ########################################################


  ##############################
  def get_object_id(object_name)
    object_type = get_object_type(object_name)

    unless object_type == 'interceptor'
      return instance_variable_get("@#{object_type}_ids")[object_name]
    else
      return instance_variable_get("@#{object_type}s")[object_name]['id']
    end
  end ## def get_object_id(object_name)


  #################################
  def get_object_birth(object_name)
    object_type = get_object_type(object_name)

    return instance_variable_get("@#{object_type}")[object_name]['birth']
  end ## def get_object_id(object_name)


  #################################
  def get_object_death(object_name)
    object_type = get_object_type(object_name)

    return instance_variable_get("@#{object_type}")[object_name]['death']
  end ## def get_object_id(object_name)


  #############################
  def get_class_id(object_name)
    object_type = get_object_type(object_name)
    object_class = get_object_class(object_name).to_s.downcase

    return instance_variable_get("@#{object_type}_class_ids")[object_class]
  end ## def get_class_id(object_name)


  #########################################
  def get_event_id(object_name, event_name)
    object_type = get_object_type(object_name)

    return instance_variable_get("@#{object_type}_event_ids")[event_name]
  end ## def get_event_id(object_name, event_name)


  ################################
  def get_object_type(object_name)
    object = check_cache_for(object_name)
    if object.nil?
      if object_name.is_battery?
        return 'battery'
      else
        fatal_error("Unexpected object type for: #{object_name}.")
      end
    end

    return get_proper_object_class(object_name)
  end ## def get_object_type(object_name)


  ## returns the lower case string of the class name for the object
  #################################
  def get_object_class(object_name)
    object = check_cache_for(object_name)

    if object.nil?
      if object_name.is_battery?
        launcher_names = get_from_cache('launcher_names')

        launcher_names.each do |launcher_name|
          battery_name = get_from_cache(launcher_name, :battery_name)

          if battery_name == object_name
            return get_from_cache(launcher_name, :class)
          end
        end
        fatal_error("Couldn't find a battery called: #{object_name}.")
      else
        fatal_error("Unexpected object class for: #{object_name}.")
      end
    end

    return object.class
  end


  ########################################
  def get_proper_object_class(object_name)
    object_ancestors = get_object_class(object_name).ancestors

    object_class = nil

    object_ancestors.each do |a_class|
      object_class = @object_type[a_class.to_s.downcase]

      ## quit when we find it
      break unless object_class.nil?
    end

    fatal_error("Unexpected object class for object: #{object_name}.") if object_class.nil?

    return object_class
  end


  #############################################
  def get_object_table(table_type, object_name)
    object_type = get_object_type(object_name)
    
    return instance_variable_get("@#{table_type}_tables")[object_type]
  end




  ########################################################
  ##   CONDITION STRING GENERATOR FOR DATABASE SEARCHES
  ########################################################


  ####################################
  def get_condition_string(conditions)
    condition_string = ''

    conditions.each_pair do |column, value|
      condition_string << ' AND ' unless condition_string.length == 0
      if value.class == Hash
        condition_string << "#{column} #{value['comparitor']} '#{value['value']}'"
      else
        condition_string << "#{column} = '#{value}'"
      end
    end ## conditions.each_pair do |column, value|

    return condition_string
  end ## def get_condition_string(conditions)


  #################
  def get_guid_hash
    return {'GUID' => @run_data.GUID}
  end ## def get_guid_hash


  ##################################################
  def get_relative_time_hash(time, comparitor = '=')
    cond_hash = {'comparitor' => comparitor, 'value' => time - @run_data.start_time}

    return {'relative_time' => cond_hash}
  end ## def get_relative_time_hash(time, comparitor = '=')


  ##############################################
  def get_event_id_hash(object_name, event_name)
    return {'runtime_event_id' => get_event_id(object_name, event_name)}
  end ## def get_event_id_hash(object_name, event_name)


  ###################################
  def get_object_id_hash(object_name)
    object_type  = get_object_type(object_name)

    return {"runtime_#{object_type}_id" => get_object_id(object_name)}
  end ## def get_object_id_hash(object_name)


  #################################
  def get_self_id_hash(object_name)
    return {"id" => get_object_id(object_name)}
  end


end ## class CacheLogger


############################
## Initialize the event loop

#puts "ctrl-c to quit."


EM.run do
  ## initialize
  status = SharedMemCache.get('sim_status').to_s

  puts("Simulation #{status}...")

  if sim_running? or sim_paused? or status == 'loaded'
    if sim_running? or sim_paused?
      puts('Simulation already in progress, initialize logger!')
      puts('We probably missed something.')
    end
    
    logger = CacheLogger.new
  end

  ## run logger
  EM::add_periodic_timer( 1 ) do
    new_status = SharedMemCache.get('sim_status').to_s

    if status != new_status
      status = new_status
      puts("Simulation #{status}...")

      logger = CacheLogger.new if status == 'loaded'
    end

    logger.log_runtime_data if sim_running? or sim_paused?
  end ## EM::add_periodic_timer( 1 ) do
end ## EM.run do

############################
## Event loop has terminated

#log_this "Done."

