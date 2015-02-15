#############################################################
###
##  File:  Launcher.rb
##  Desc:  Generic Launcher Class
#

require 'Interceptor'
require 'EngagementZone'
require 'ostruct'

class LauncherTimeData

  attr_accessor :first_intercept_time
  attr_accessor :first_launch_time
  attr_accessor :fos_first                # flyout seconds (fos)
  #
  attr_accessor :last_intercept_time
  attr_accessor :last_launch_time
  attr_accessor :fos_last
  #
  attr_accessor :bid_factor               # used by Toc class
  
  def initialize
    @first_intercept_time   = 0.0
    @first_launch_time      = 0.0
    @fos_first              = 0.0
    #
    @last_intercept_time    = 0.0
    @last_launch_time       = 0.0
    @fos_last               = 0.0
    #
    @bid_factor             = 0.0  
  end
  
end ## end of class LauncherTimeData 

#############################################################
# A generic launcher class
class Launcher
  
  # FIXME: Encoding information within a label is not a good idea.
  # The label by which this launcher is known.  The current
  # naming convention uses STK object path's baselabel. Follows
  # a standard naming convention like: BLPac3_123.  The 'BL'
  # means blue force launcher.  The characters following 'BL' up to the
  # '_' identify the type of rounds fired by the launcher.  The number
  # following the underscore is a unit identification number expressed
  # in octal.  Octal is used to ensure valid track_id values when used
  # in Link-16 messages.
  attr_accessor :label

  # The type of a launcher determines what kind of rounds (interceptors)
  # that is fires. Example:"Pac3", "Thaad", "GemT"
  attr_accessor :type

  # A 3 digit octal number as a string.  Octal is used to ensure compatability
  # with the track_id requirements of most Link-16 messages.
  attr_accessor :unit_id

  # STK Object Path
  attr_accessor :sop
  
  # Hash of rounds expended
  attr_accessor :rounds             
  
  # standard number of rounds per individual launcher
  attr_accessor :standard_rounds    
  
  # number of rounds currently abailable to fire.  Does not include
  # any rounds that are sitting in reload containers.
  attr_accessor :rounds_available   
  
  # number of rounds fired
  attr_accessor :rounds_expended    
    
  # Launcher's location in decimal degrees and meters.  An LlaCoordinate
  # object consisting of latitude, longitude and altitude.
  attr_accessor :lla
  
  # Launcher status
  attr_accessor :status
  
  # The standard operating procedure of the launcher w/r/t TBM threats.  Examples are
  # :shoot, :shoot_shoot, :shoot_look_shoot, :shoot_shhot_shoot etc.
  # The tbm_doctrine effects the number of rounds fired against a TBM target.  A
  # tbm_doctrine of :shoot will fire only one round per engagement.  A tbm_doctrine of
  # :shoot_shoot will fire two rounds per engagement.
  attr_accessor :tbm_doctrine

  # The standard operating procedure of the launcher w/r/t ABT threats.  Examples are
  # :shoot, :shoot_shoot, :shoot_look_shoot, :shoot_shhot_shoot etc.
  # The abt_doctrine effects the number of rounds fired against an ABT target.  A
  # abt_doctrine of :shoot will fire only one round per engagement.  A abt_doctrine of
  # :shoot_shoot will fire two rounds per engagement.
  attr_accessor :abt_doctrine

  # The label of the battery to which this launcher belongs  
  attr_accessor :battery_label
  
  # The number of launchers in a battery.
  # SMELL: out of place; needs to be in some kind of Battery class
  attr_accessor :battery_size
  
  # label of the TOC to which this battery/launcher is attached
  attr_accessor :toc_label
  
  # in meters; organic sensor with battery
  # SMELL: makes no sense that a launcher needs to know the range of
  # a sensor attached to the same battery as the launcher.
  attr_accessor :sensor_range
 
  # Number of times the launcher has been reloaded
  attr_accessor :reloads_expended   
  
  # Number of reloads currently available.
  attr_accessor :reloads_available
  
  # reloads available in a standard config
  attr_accessor :standard_reloads
  
  # The total number of seconds in the simulation.
  attr_accessor :sim_length_seconds
  
  # Minimum number of seconds the interceptor can fly before gaining
  # sufficient kinetic energy to enable hit-to-kill
  attr_accessor :minimum_flyout_seconds
  
  # How long the current interceptor is flying to its target
  attr_accessor :flyout_seconds
  
  # How long it takes a launcher to configure/initialize an interceptor for launch
  # The earliest time after receipt of an engagement that a launch can occure
  attr_accessor :interceptor_initialization_seconds
  
  # For use when no Pk table is available
  attr_accessor :standard_pk_air
  attr_accessor :standard_pk_space
  attr_accessor :pk_air
  attr_accessor :pk_space


  # Default velocity for the interceptor
  # units in meters per second
  attr_accessor :standard_interceptor_velocity

  # Engagement Zone - A hash indexed by target label of
  # EngagementZone objects.  An engagement zone contains the
  # probable kill (Pk) table for a range of earliest intercept time
  # to latest intercept time.
  attr_accessor :ez                 

  # a theoritical cost of using this launcher's round.
  # associated with force provisioning process.
  # This is really the cost of the round, not the launcher.  Makes
  # more sense to move it into a class for the round.  Doing so
  # would allow the Launcher class to support hybrid launchers
  # capable of firing different rounds concurrently.
  attr_accessor :cost_factor
  
  # A hash of open structures that presists the time data associated with
  # an engagement.  Elements are at least:
  #   first and last time to intercept
  #   first and last time to launch
  # The key to the hash is a threat_label
  attr_accessor :time_data
  
  # The Tracking Radar associated with this launcher.  The tracking
  # radars are typically of class StaringRadar.
  attr_accessor :tracking_radar


  # This is the user inputted max range from the Mission Planning GUI
  # to be used along with the standard pk's if a pk table does not
  # exist for a certain threat-interceptor combination (as long as the
  # pk is non-zero)
  attr_accessor :max_range
  
  # TODO: need max_altitude as well
  
  # A Hash keyed by threat_label of arrays that summarizes why
  # a threat can not be engaged
  attr_accessor :why
  
  ##########################################################
  
  include Observable
  
  def initialize(label, lla)
    
    # FIXME: Encoding information within a label is not a good idea.
    # naming convention like: BLPac3_123
    
    a=label.split('_')
    @label     = label
    @type     = a[0]
    @type     = @type[2,@type.length-2]
    @unit_id  = a[1]
    

    @standard_rounds  = 0
    @rounds_expended  = 0
    
    case lla.class.to_s
      when 'Array' then
        @lla              = LlaCoordinate.new lla
      when 'LlaCoordinate' then
        @lla              = lla
      else
        die "Don't know how to handle lla.class: #{lla.class}"
    end
    
    @status           = :ready
    
    @rounds           = Hash.new
    
    @tbm_doctrine             = :shoot  ## or :shoot_shoot or :shoot_look_shoot etc.
    @abt_doctrine             = :shoot  ## or :shoot_shoot or :shoot_look_shoot etc.
    
    @sop              = nil
    
    @battery_size     = 1     # Allows class to represent a single launcher or a co-located group
    @battery_label     = nil

    @standard_reloads   = 0
    @reloads_expended   = 0
    @reloads_available  = @standard_reloads
    
    @sensor_range       = 30000   # TODO: Get data from IDP's xml file
    
    @sim_length_seconds = ($sim_time.end_time - $sim_time.start_time).to_i
    
    @toc_label          = nil
    @ez                 = Hash.new
    
    @interceptor_initialization_seconds = 3  # The earliest time after receipt of an engagement that a launch can occure
    @minimum_flyout_seconds             = 4  # How long an interceptor must fly to gain sufficient energy for hit-to-kill
    
    # Force Provisioning defaults
    @cost_factor        = 1.0 # generic cost factor; expected to over-ridden by sub-class
    

    
    @standard_pk_air     = 95
    @standard_pk_space   = 90
    
    @standard_interceptor_velocity = 2000.0   # meters per second
    
    @time_data            = Hash.new
    @launch_time          = Hash.new
    @flyout_seconds_hash  = Hash.new
    @threat_engagability  = Hash.new
    @why                  = Hash.new
    
  end

  ######################################################
  # dump the contents of the @why attribute
  def tell_me_why(a_threat)
    threat_label = a_threat if 'String' == a_threat.class.to_s
    threat_label = a_threat.label unless 'String' == a_threat.class.to_s
    s = "  Unrecorded."
    if @why.include?(threat_label)
      unless @why[threat_label].empty?
        s = ""
        @why[threat_label].each { |w| s += '  ' + w + "\n" }
      end
    end
    return s
  end

  ###########################################
  # Do what is neccessary to ready a round for firing.
  # The minimum is to adjust the rounds available and
  # rounds expended stats.  Subclasses are expected to
  # Over-ride this method with a yeild to the super class
  # to ensure correct stats.
  def ready_a_round
    @rounds_available   -= 1
    @rounds_expended    += 1
  end
  
  ###########################################
  # Do what is neccessary to restock a round previously allocated
  # to an engagement but subsequently canceled.
  # The minimum is to adjust the rounds available and
  # rounds expended stats.  Subclasses are expected to
  # Over-ride this method with a yeild to the super class
  # to ensure correct stats.
  def restock_a_round
    @rounds_available   += 1
    @rounds_expended    -= 1
  end

  
  
  ##################################
  # Cancel all rounds await fire order for an engagement against a specific target.
  # A round that has already been launched or is in the process of being launched can not
  # be canceled.  In these cases a self destruction message must be sent to the round
  # when it is at a safe distance away from the launcher.
  def cancel_engagement(threat_obj)
  
    threat_label = threat_obj.label
  
    log_this "Attempting to cancel an engagement by #{@label} against threat #{threat_label}"
    
    was_it_canceled = false
    
    @rounds.each_pair do |interceptor_label, rock|
      next unless rock.target_label == threat_label
      
      if rock.launch_time > $sim_time.sim_time
      
        log_this "... interceptor has not yet launched."
      
        # Tell STK to delete the object
        # ra = putstk "unload / #{rock.sop}"
        # puts "... told STK to unload object, got ra: #{ra.pretty_inspect}"
        
        rock.sop = nil
        #$engagement_cancelled.record_event(@label, rock.label)
        
        # change state of round
        rock.state = :canceled
        
        # change the engaged_by entry in the target
        threat_obj.engaged_by.delete(interceptor_label)
        
        log_this "... removed #{interceptor_label} from #{threat_obj.label}'s engaged_by hash."
        
        # Return round to available inventory
        restock_a_round
        was_it_canceled    = true   # SMELL: shoot-shoot may have missed the first and got the second round
      else
        log_this "... too late, interceptor has been launched or is launching now."
      end
      
    end ## end of @rounds.each_pair do |interceptor_label, rock|
    
    return was_it_canceled
    
  end ## end of def cancel_engagement(threat_label)
  
  ####################################################################
  # This method is an engagement order not a launch
  # order.  The intent is to order the launcher to engage a specific target.  It
  # is the responsibility of the firing computer to determine when the round is
  # actually "launched."
  def engage(target)
  
    log_this "#{@label} with status #{@status} received engage order against target #{target.label}"
    
    launcher_doctrine = target.label.is_missile? ? @tbm_doctrine : @abt_doctrine
    rounds_required   = num_of_shoots(launcher_doctrine)

    if 0 >= rounds_required
      log_event "#{@label} launcher_doctrine of #{launcher_doctrine} precludes engagements against #{target.label}"
      return nil
    end

    unless ready?
      log_event "#{@label} is not ready to handle engagements although one has been requested against #{target.label}"
      return nil
    end

    unless can_engage?(target)
      log_event "#{@label} can not engage #{target.label}"
      return nil
    end
    
    rounds_ready = Array.new
    
    if 0 == @rounds_available
      @status = :out_of_service
      $engagement_failure.record_event(@label, @status)
      return rounds_ready
    end
    
    # Launch Next Tube
    @status                 = :launching
    

    # Treat the :shoot_look_shoot doctrine as if it were just :shoot
    # in order to not "ready" a 2nd round until after the first one
    # misses.
    
    if :shoot_look_shoot == launcher_doctrine
      rounds_required -= 1
    end

    rounds_required.times do |shot_number|
      if @rounds_available > 0

        a_round                 = ready_a_round   # construct a new interceptor instance
        a_round.launcher_label  = @label
            
        a_round.pk  = @ez[target.label].max[0]

        ez_time_ratio = (shot_number).to_f / rounds_required.to_f
        time_range    = @ez[target.label].range
        ez_time       = (time_range.last - time_range.first) * ez_time_ratio + time_range.first
        
        pip_time = $sim_time.start_time + ez_time.to_i
        
        
        # debug_me("TimeMachine"){ [:pip_time, "@ez[target.label].range"] }  if $debug
        
        flyout_seconds = @flyout_seconds_hash[target.label][ez_time.to_i]

        a_round.launch_against(target, @label, pip_time, flyout_seconds)
        
        rounds_ready << a_round.label unless :mis_fire == a_round.state
        @rounds[a_round.label] = a_round

      else
        log_this "launcher_doctrine was #{launcher_doctrine} but no additional rounds were available"
        $engagement_failure.record_event(@label, "#{launcher_doctrine} round number #{shot_number} not available")
      end
    end
    
    puts "DEBUG: launcher.engage is returning: #{rounds_ready.pretty_inspect}"

    @status = :ready
    
    return rounds_ready
    
  end  ## end of def engage(target)

  
  #######################
  # Ask the launcher if it has the ability to engage a specific target.
  # returns true or false
  def can_engage?(target)
  
    threat_label = target.label
    
    @why[threat_label] = Array.new unless @why.include?(threat_label)
    
    #######################################################
    ## First consider the launcher's current status
    
    launcher_doctrine = threat_label.is_missile? ? @tbm_doctrine : @abt_doctrine
    rounds_required   = num_of_shoots(launcher_doctrine)
  
    log_this "... #{@label} is thinking about engaging #{threat_label}."
    
    unless ready?
      log_event "Not Ready."
      @why[threat_label] << "Launcher is not in ready state."
      return false
    end
    
    # launcher is ready with at least 1 interceptor
    
    if rounds_required > @rounds_available
      log_event "Insufficient Rounds Available."
      @why[threat_label] << "Insufficient rounds available.  Need #{rounds_required} have #{@rounds_available}"
      return false
    end

    ################################################
    ## At this point the current launcher's status
    ## indicates that it is available with sufficient rounds.

    if update_engagement_zone(target) # returns true if the threat can be reached along its predicted path
      mpka = @ez[target.label].max
      log_event "EZ exists with maximum Pk of #{mpka[0]} at #{mpka[1]} -- #{$sim_time.start_time+mpka[1]}"
      engagabile = ( not mpka[0].nil? ) && (mpka[0] > 0) # @ez[threat_label].pk.max > 0
    else
      debug_me "CAN NOT ENGAGE"
      @why[threat_label] << "An engagement zone does not exist."
      engagabile = false
    end
    
    return engagabile
    
  end ## end of def can_engage?(target)




  #############################################################
  ## Create an engagement zone for a new target
  ## returns true or false if target is engagable
  def create_engagement_zone(target)

    threat_label  = target.label
    
    threat_type   = :missile
    threat_type   = :aircraft if threat_label.is_aircraft?

    ######################################################################
    ## First check the basics; did you ask in sufficient time to even try?
        
    nto                     = $sim_time.now.to_i                          # now-time offset
    earliest_launch_time    = nto + @interceptor_initialization_seconds
    earliest_intercept_time = earliest_launch_time + @minimum_flyout_seconds

    debug_me {[:nto, :earliest_launch_time,:earliest_intercept_time]}  if $debug

    
    if earliest_launch_time > @sim_length_seconds # length of the simulation in whole seconds
      log_event "Earlist Launch Time #{earliest_launch_time} is beyond end_of_sim: #{@sim_length_seconds}"
      @why[threat_label] << "Earlist Launch Time #{earliest_launch_time} is beyond end_of_sim: #{@sim_length_seconds}"
      return false
    end
    
    if earliest_intercept_time > @sim_length_seconds
      log_event "Earlist intercept Time: #{earliest_intercept_time} is beyond end_of_sim: #{@sim_length_seconds}"
      @why[threat_label] << "Earlist intercept Time: #{earliest_intercept_time} is beyond end_of_sim: #{@sim_length_seconds}"
      return false
    end

    ########################################################
    ## Now lets check some specifics about the trheat
      
    
    # debug_me('LAUNCHER-EZ') {["@label", "threat_label"]}  if $debug
    
    
    # Setup the Pk data for this weapon-target pair
    weapon_type   = @type
    tgt_type      = target.type
    pk_key        = "#{weapon_type}_#{tgt_type}".downcase
    pk_slice      = $pk_tables[pk_key]    # could be nil if no Pk table exists



    # initialize the standard Pk for non-Pk-table weapon-target pairs
    standard_pk = 0
    standard_pk = @standard_pk_air    if threat_label.is_aircraft?   
    standard_pk = @standard_pk_space  if threat_label.is_missile?   

    if pk_slice
      debug_me {[ :threat_label,:weapon_type,:tgt_type,:pk_key,
                  "pk_slice.class",
                  "pk_slice.length",
#                  "pk_slice[0].class",
#                  "pk_slice[0].length",
                  :standard_pk]}  if $debug
    else
      debug_me {[ :threat_label,:weapon_type,:tgt_type,:pk_key,
                  "pk_slice",
                  :standard_pk]}  if $debug
    end    
    
      
   
    # Start with all zeros for Pk
    zeros = Array.new
    @sim_length_seconds.times {|x| zeros << 0}
    


    
    # NOTE: position_of_target is an array from now to the end of the prediction window
    #       entry [0] in the array represents the now position of the threat
    position_of_target    = target.predict_trajectory_absolute
    
    # MAGIC: 2 = 1 + 1 because, arrays are zero indexed AND we want the next to last entry
    next_to_last_trajectory_index = position_of_target.length - 2


    
    # NOTE: ez_range represents the widest time span in which an intercept may be possible
    # TODO: replace @sim_length_seconds with the impact_time_in_absolute_sim_seconds
    #       this will narror the range and speed up processing
    ez_range  = (earliest_intercept_time..@sim_length_seconds)    # the first engagenent zone range
 
 
    debug_me {:ez_range}  if $debug
 
    
    # NOTE: the dz_range is defined later in this process flow
    
    dz_pk     = Array.new    # detection zone
    
    
    first_detection_time  = -1
    last_detection_time   = 0
    
    # Look at the position of the target within the predicted time span to narrow the intercept times
    # that a span that is able to be accomplished.

    @flyout_seconds_hash[threat_label] = Array.new
    @launch_time[threat_label]         = Array.new

    # debug_me('EZRANGE'){[:ez_range,:earliest_launch_time, :earliest_intercept_time, :nto, "@sim_length_seconds"]}
    
    # these d_* variables are used to record closest approach of the threat to a
    # launcher that does not use PkTables... like shorad and seabased.
    d_max     = 9999999.9   # a big number
    d_min     = d_max       # minimum distance to target (hypotenuse)
    d_min_t   = nil
    d_min_r   = nil
    d_min_a   = nil
    d_min_lla = nil
    d_r_min   = d_max       # minimum range to target (ground distance)
    d_a_min   = d_max       # minimum altitude of target


    min_range_to_target = 999999.9
    az_at_min_range     = 777777.7
    min_azimuth         = 999999.9
    min_alt             = 999999.9

    max_range_to_target = -999999.9
    max_azimuth         = -999999.9
    max_alt             = -999999.9
    


    
    ez_range.each do |t|    # t is a future time; integer; absolute sim time in seconds
                            # it begins at the earliest_intercept_time and goes to the end of the sim

      # only work on valid positions
      unless position_of_target[t].nil?
        
        threat_in_terminal_phase = true
        
        # NOTE: ASSUMES we have predicted the trajectory all the way to impact
        
        if :missile == threat_type
          unless t > next_to_last_trajectory_index
            alt_now   = position_of_target[t].alt
            alt_next  = position_of_target[t+1].alt
            alt_delta = alt_now - alt_next
            
            
         debug_me('THREAT-PHASE-PROCESS'){[:t, :alt_delta, :alt_now, :alt_next]}  if $debug
            
            
            threat_in_terminal_phase = (alt_delta > Trajectory::CRUISE_DELTA)
          end
        end

=begin
## FIXME: This approach based upon heading does not work.
##        Consider mods to radar ThreatWarning

        if :aircraft == threat_type
        
          # NOTE: this algorythm ASSUMES that there is only one leg of the
          #       trajectory that is heading toward the impact point.  Complex
          #       trajectories may have multiple disjoint legs that meet the
          #       criteria for a terminal leg.  No idea how these complex
          #       trajectories will be handled by the existing code base which
          #       will generate a disjoint engagement zone.
          unless t > next_to_last_trajectory_index
            point_now     = position_of_target[t]
            point_next    = position_of_target[t+1]
            point_last    = position_of_target.last
            bearing_now   = point_now.heading_to point_next
            bearing_last  = point_now.heading_to point_last
            bearing_delta = (bearing_now - bearing_last).abs
            # Special case: North (0 degrees) is between bearing now and bearing last
            if bearing_delta >= Trajectory::NORTH_DIFF
              threat_in_terminal_phase = true
            else  # normal case - bearings are on the same side of north
              threat_in_terminal_phase = (bearing_delta <= Trajectory::BEARING_DELTA)
            end
          end
          
          unless threat_in_terminal_phase
            # invalidate the position to prevent bids on aircraft that are not 
            # on their terminal leg
            position_of_target[t] = nil unless t >= next_to_last_trajectory_index
          end

          # TODO: Add capability to identify a threat that is "flying through" a defended
          #       area even though it may not be flying toward an impact point

        end ## end of if :aircraft == threat_type
=end

      end ## end of unless position_of_target[t].nil?


      
      # For each of these positions, we need to ask the
      # tracking_radar if it can_detect? the threat.  If so, then
      # get the Pk for that range and altitude; otherwise the Pk is zero.

      unless position_of_target[t].nil?                  # If we know where the target will be then

        if threat_in_terminal_phase
          
          range_to_target = range_to(position_of_target[t])     # meters
          azimuth         = azimuth_to(position_of_target[t])   # degrees
          alt             = position_of_target[t].alt           # meters
   
   
          if range_to_target  < min_range_to_target
            az_at_min_range     = azimuth
            min_range_to_target = range_to_target
          end
          
          min_azimuth         = azimuth         if azimuth          < min_azimuth 
          min_alt             = alt             if alt              < min_alt

          max_range_to_target = range_to_target if range_to_target  > max_range_to_target
          max_azimuth         = azimuth         if azimuth          > max_azimuth 
          max_alt             = alt             if alt              > max_alt
           
          
          @flyout_seconds_hash[threat_label][t] = range_to_target / @standard_interceptor_velocity  # standard_interceptor_velocity in meters per second
          @launch_time[threat_label][t]         = t - @flyout_seconds_hash[threat_label][t]

          
          # puts "ST: #{t}  Range to Tgt: #{range_to_target} at #{position_of_target[t]}" if $debug

          if @tracking_radar.can_detect?(position_of_target[t])
            
            unless @launch_time[threat_label][t] < earliest_launch_time # was t  # do not launch in the past
                      
              first_detection_time  = t unless first_detection_time >= 0
              last_detection_time   = t
              
              if pk_slice
                # Use the data from the PkTable
                pk_from_file = pk_slice['pk'].at(range_to_target, alt)
                debug_me {[:pk_from_file, :range_to_target, :alt]} if $debug
                dz_pk << pk_from_file    # PK within the detection zone
              else
                # Use the standard Pk
                d,r,a   = beeline_to(position_of_target[t])
                if d < d_min
                  d_min     = d
                  d_min_t   = t
                  d_min_r   = r
                  d_min_a   = a
                  d_min_lla = position_of_target[t]
                end
                d_r_min = r if r < d_r_min
                d_a_min = a if a < d_a_min
                if d <= @max_range
                  debug_me {[:standard_pk, :range_to_target, :alt]} if $debug
                  dz_pk << standard_pk
                else
                  dz_pk << 0
                end
              end ## end of if pk_slice
              
            end   ## end of if @launch_time[threat_label][t] < t
            
          end ## end of if @tracking_radar.can_detect?(position_of_target[x])
        
        end ## end of if threat_in_terminal_phase

      end ## end of unless position_of_target[t].nil?
      
    end   ## end of ez_range.each do |t|
      
    # ez_pk is an array of Pk for the relative to now time span first ..last intercept_relative_time
    
   
    # NOTE: The @time_data structure is more realistic than the ez_range related data because @time_data takes
    #       in to account distance to target and a standard velocity for the interceptor.  The older way used a
    #       fixed flyout time for each interceptor type... so regardless of how far away the target was, the old
    #       way took exactly the same number of seconds to fly the interceptor to the PIP.
     
    if first_detection_time < 0
      log_event "Engagement Not Possible - Relative Detection Time First: #{first_detection_time}   Last: #{last_detection_time}"
      @why[threat_label] << "Search radar's projected track of threat is not visible to the tracking radar."
      if min_range_to_target > @tracking_radar.range[1]
        @why[threat_label] << "Minimum range to target (#{min_range_to_target} meters) is greater than tracking radar's maximum range: #{@tracking_radar.range[1]} meters."
      else
        @why[threat_label] << "The following details are provided with the cavaet that overlaps in range"
        @why[threat_label] << "and azimuth must occure at the same time.  Although the minimum range to target"
        @why[threat_label] << "is within the ability of the radar, it may have occured at an azimuth outside"
        @why[threat_label] << "of the radar's sector."
        @why[threat_label] << "Range to target    (min..max): (#{min_range_to_target} ..  #{max_range_to_target}) meters."
        @why[threat_label] << "  Tracking radar   (min..max): (#{@tracking_radar.range.join(' .. ')}) meters."
        @why[threat_label] << "Azimuth to target  (min..max): (#{min_azimuth} .. #{max_azimuth}) degrees."
        @why[threat_label] << "  Tracking radar   (min..max): (#{@tracking_radar.azimuth_min} .. #{@tracking_radar.azimuth_max}) degrees."
        @why[threat_label] << "  Azimuth to tgt @ min. range: #{az_at_min_range} degrees."
        @why[threat_label] << "Altitude of target (min..max): (#{min_alt} .. #{max_alt}) meters."
      end
      @why[threat_label] << "Positive control of interceptor is not possible."
      return false
    end

  
    # detection zone time span for use in determining engagement zone
    dz_range = ( first_detection_time .. last_detection_time )
    

    debug_me("DZRANGE"){[:first_detection_time, :last_detection_time, :dz_range]}  if $debug
    


    pk_table = zeros.dup
    pk_table[dz_range] = dz_pk
      


    engagement_zone = EngagementZone.new(@label, threat_label, pk_table)
    
    debug_me {["pk_table.class", "pk_table.length","engagement_zone.to_s"]}  if $debug
    

    if engagement_zone.range.nil?
      log_event "Engagement Not Possible - Launcher #{@label} detected Threat #{target.label}, but could not Engage"
      unless d_min == d_max
        @why[threat_label] << "Target did not come within range of the launcher." if d_min > @max_range
        @why[threat_label] << "  Minimum distance to target: #{d_min} meters."
        @why[threat_label] << "         occured at sim_time: #{d_min_t}  lla: #{d_min_lla.join(', ')}"
        @why[threat_label] << "              hypot_by_pthag: d_min_r: #{d_min_r} d_min_a: #{d_min_a}"
        @why[threat_label] << "                     sqrt of: (#{d_min_r**2} + #{d_min_a**2} )"
        @why[threat_label] << "       Distance Verification: #{Math.sqrt(d_min_r**2 + d_min_a**2)}"
        @why[threat_label] << "Maximun range of interceptor: #{@max_range} meters"
        #@why[threat_label] << "Minimum ground range to target: #{d_r_min} meters."
        #@why[threat_label] << "Minimum altitude of target:     #{d_a_min} meters."
      else
        @why[threat_label] << "Not engageable according to PkTable."
      end
      return false
    end


  
    first_intercept_time = engagement_zone.range.first  # NOTE: An engagement zone might have gaps
    last_intercept_time  = engagement_zone.range.last   #       The range (sim-relative-time units) represents the outter edges

    # SMELL: confused about the units of measure
    # SMELL: This range has not been adjusted for earliest_launch_time and earliest_intercept_time

    debug_me("FirstEngagementZoneRange"){[:threat_label, :nto, :dz_range,
              "engagement_zone.range", 
              :first_intercept_time, :last_intercept_time]}  if $debug



    ## Create a @time_data entry for this threat if one does not already exist.
    ## Actually one should not exits because this is the first time an engagement zone has been created
    @time_data[threat_label]  = LauncherTimeData.new unless @time_data.include?(threat_label)
    

  debug_me('LAUNCH-TIME-ARRAY'){[:threat_label, '@launch_time[threat_label].length', '@launch_time[threat_label]']}  if $debug
    
    @time_data[threat_label].first_intercept_time  = first_intercept_time
    @time_data[threat_label].first_launch_time     = @launch_time[threat_label][first_intercept_time]
    @time_data[threat_label].fos_first             = @flyout_seconds_hash[threat_label][first_intercept_time] 

    @time_data[threat_label].last_intercept_time   = last_intercept_time
    @time_data[threat_label].last_launch_time      = @launch_time[threat_label][last_intercept_time]
    @time_data[threat_label].fos_last              = @flyout_seconds_hash[threat_label][last_intercept_time]
    


    debug_me("TimeData"){[
      :threat_label,
      "@time_data[threat_label]",
      "@time_data[threat_label].first_intercept_time",
      "@time_data[threat_label].first_launch_time",
      "@time_data[threat_label].fos_first",
      "@time_data[threat_label].last_intercept_time",
      "@time_data[threat_label].last_launch_time",
      "@time_data[threat_label].fos_last"
    ]}  if $debug



  
    if engagement_zone.pk.empty?
      @ez.delete(threat_label)
      log_event "EZ no longer exists for #{target.label}"
      return false
    end

    @ez[threat_label] = engagement_zone
    
    # debug_me('LAUNCHER-EZ') {["@label", "@threat_label", "@ez[threat_label]"]}  if $debug
    
    return true

  end ## end of def create_engagement_zone(target)




  ###################################################
  # Create or Update and Engagement Zone for a threat
  # If an engagement zone does not exist, it is created.
  # A nil engagement zone means the target is not engagable.
  # If an engagement zone already exists, then update the time
  # data based upon the current sim time.
  # returns true or false if target is engagable
  def update_engagement_zone(target)

    threat_label = target.label

    debug_me('LAUNCHER-EZ') {["@label", "threat_label"]}  if $debug

    if @ez[threat_label].nil?
      # Engagement zone does not exist for target, and therefore needs to be created.
      engagable = create_engagement_zone(target) # returns true or false based upon wither the target can be engaged
    else 
      # Engagement zone already exists for this target, we just need to update the first intercept
      # and first launch times based on flyout_seconds and interceptor_initialization_seconds
      # NOTE: interceptor_initialization_seconds is a hold over from when the master clock for the simulation was STK.
      #       This gets wrapped up and confused with the intent of the instance attribute
      #       @flyout_seconds which was originally designated as the minimum number of seconds
      #       that this weapon system requires to succesfully engage a target.  Since
      #       the fidelity of the interceptor has been increated by calculation of the
      #       actual flight time to the target based upon average velocity and range to
      #       the target, flyout_seconds has been overloaded.  See Issue:105

      old_first_intercept_time = @time_data[threat_label].first_intercept_time
      old_first_launch_time    = @time_data[threat_label].first_launch_time
      last_intercept_time      = @time_data[threat_label].last_intercept_time
      last_launch_time         = @time_data[threat_label].last_launch_time

      nto = $sim_time.now.to_i
      first_launch_time = nto + @interceptor_initialization_seconds


      if nto < old_first_launch_time 
        # current time has not surpassed the first launch time, so no update to @ez is necessary
        return true
      end

      if nto > last_launch_time
        log_event "The current time #{nto} has surpassed the last launch time: #{last_launch_time}, so the launcher can no longer engage"
        @why[threat_label] << "After last launch opportunity: #{last_launch_time}"
        return false
      end

      first_intercept_time = 0

      @launch_time[threat_label].each do |launch_time|
        unless launch_time.nil?
          if launch_time >= first_launch_time
            break
          end
        end
        first_intercept_time += 1
      end


      @ez[threat_label].range = (first_intercept_time .. last_intercept_time)
      @ez[threat_label].update_pk

      @time_data[threat_label].fos_first            = @flyout_seconds_hash[threat_label][first_intercept_time]
      @time_data[threat_label].first_intercept_time = first_intercept_time
      @time_data[threat_label].first_launch_time    = @launch_time[threat_label][first_intercept_time]

      engagable = true
      
    end

    return engagable

  end # end of def update_engagement_zone(target)


  #################################################################################
  # An odd method which basically returns the engagement zone for a specific target
  def bid_on(target)
  
    can_engage?(target) unless @ez[target.label]

    return @ez[target.label]  # will either be nil (no bid) or a valid engagement zone
    
  end


  ##########
  # Reload the launcher with new rounds from a reloading container.  This will take the
  # launcher off-line while the reloading process is underway.
  # FIXME: Add a timer function that allows the launcher to come back online when it is done with the reload.
  def reload
    @status               = :reloading
    if @reloads_available > 0
      @rounds_available   = @standard_rounds * @battery_size
      @reloads_expended  += 1
      @reloads_available -= 1
      @status             = :ready
    else
      @status = :out_of_service
    end

  end
  
  ##########
  # Is this launcher ready to receive an engagement order
  def ready?
    return :ready == @status
  end
  
  alias :available? :ready?
  
  
    
  ###############
  # Send commands to STK to create a graphica instance of this launcher
  # within the current STK scenario.  Obtain the created STK Object Path
  # for this launcher's graphical instance.
  def send_to_stk
    @sop = create_pac3_launcher(@label, @lla)
    return @sop
  end


  
  #########
  # Place the instance of this class into an initial state.
  def reset
    @rounds_expended    = 0
    @rounds_available   = @standard_rounds * @battery_size
    @rounds             = Hash.new
    @reloads_available  = @standard_reloads
    @reloads_expended   = 0
    @pk_air             = @standard_pk_air
    @pk_space           = @standard_pk_space
  end
  
  ####################
  # Return the range (in meters) between this launcher and some other
  # location.
  def range_to(thing)
    lla = thing if 'LlaCoordinate' == thing.class.to_s
    lla = thing.lla unless lla
    return @lla.distance_to(lla, :units => :kilo) * 1000.0
  end

  ####################
  # obtain the heading/direction/azimuth between this launcher and
  # some other location.
  def azimuth_to(thing)
    lla = thing if 'LlaCoordinate' == thing.class.to_s
    lla = thing.lla unless lla
    return @lla.heading_to(lla)
  end


  # calculate hypot of triangle for hemi-sphere
  def beeline_to(thing)
    debug_me {"thing.class.to_s"} if $debug
    
    lla = thing if 'LlaCoordinate' == thing.class.to_s
    lla = thing.lla unless lla
    
    r = range_to(thing)
    a = lla.alt - @lla.alt
    d = Math.sqrt(r**2 + a**2)
    
    debug_me {["lla.alt","@lla.alt",:r,:a,:d]} if $debug
    
    return d,r,a
  end

  ########
  # Count the number of rounds fired that resulted in a hit
  def hits
    counter = 0
    @rounds.each do |r|
      counter += 1 if :hit == r.engagement_result
    end
    return counter
  end
  
  ##########
  # Return the number of rounds fired that did not result in a hit.
  def misses
    return @rounds.length - hits
  end

  ############################################################
  ## How many interceptors are required for the given doctrine
  def num_of_shoots(doctrine_str_or_symbol=nil)    
    return doctrine_str_or_symbol.to_s.scan(/shoot/).length
  end
  
=begin
  ##########################################
  # SMELL: Not sure this method really does anything useful.
  # If an engagment zone has already been calculated, this methods
  # basically erases it and then rebuilds it.
  def ez
    return @ez if @ez_last_update_time == $sim_time.sim_time
    @ez.each_key do |target_label|
      target_obj = SharedMemCache.get(target_label)
      can_engage?(target_obj) if target_obj
    end
    @ez_last_update_time = $sim_time.sim_time
    return @ez
  end

=end

end  ## end of class Launcher



require 'ShoradLauncher'
require 'Pac3Launcher'
require 'ThaadLauncher'
require 'GemtLauncher'
require 'StandardMissileLauncher'



