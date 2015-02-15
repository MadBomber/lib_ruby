######################################################
###
##  File:  Interceptor.rb
##  Desc:  Interceptor Class
#

require 'Missile'
require 'InterceptorGenerator'    ## Dynamically calculates trajectory
require 'TrajectoryGenerator'     ## Used to create a static file of the complete trajectory

require 'WarmUpInterceptor'

################################################################
class Interceptor < Missile
  
  attr_accessor :miss_factor        # seconds to be added to launch_time to simulate a miss
  attr_reader :flyout_seconds     # minimum required to fly to target
  attr_accessor :target_label       # Target label
  attr_accessor :pip_time           # Time object
  attr_accessor :pk                 # Probability of a Kill (integer 0..100)
  attr_accessor :engagement_result  # :miss or :hit
  attr_accessor :launcher_label     # label of launcher that shot this thing
  attr_accessor :standard_velocity  # meters per second
  
  # NOTE: From the Missil Class the predict_trajectory adds these attributes
  #       attr_accessor :traj_filename      # The Pathname of the *.traj file
  #       attr_accessor :trajectory         # Array of LLA points .first is the launch position; .last is the impact position
  #       attr_reader   :life_span          # The life span of this thing
  #       The Interceptor class will over-ride some of this functionality to make use of
  #       dynamically generated trajectories from the InterceptorGenerator class.  We
  #       are not using a *.traj file to communication the flight path of the interceptor.
  #       Allowing for a dynamic flight path gives us the oppertunity to later implement a
  #       higher fidelity navigation component.
  #       @traj_filename will be nil on initialization.  Once an InterceptorGenerator instance
  #       is created it will contain a dummy file name.
  
  attr_accessor :dynamic_trajectory_generator   # an instance of InterceptorGenerator


  def flyout_seconds=(some_value)
  
    pp caller if some_value.nil?
    
    @flyout_seconds = some_value
  end

  
  def initialize( label=nil,          # There is a naming convention see aadse_utilities
                  launch_lla=nil,     # Where the interceptor is to be launcher from as an LlaCoordinate
                  impact_lla=nil,     # The Predicted Intercept Point as an LlaCoordinate
                  launch_time=nil,    # When the interceptor is to be launched
                  flyout_seconds=nil  # How long it will take the interceptor to fly to the target
                )

  debug_me{[:@label, :@flyout_seconds]}  if $debug

    unless 'BM' == label[0,2]
      next_unit_id      = get_next_unit_id
      @unit_id          = sprintf("%03o", next_unit_id)
      @label            = 'BM' + label + '_' + @unit_id
    else
      @label            = label
      @unit_id          = label.split('_')[1]
    end
    
    @track_id         = @label[0,2] + @unit_id
    


    super(@label, launch_lla)



    @miss_factor      = 2.0             # Number of seconds to arrive late or early at the pip; simulates a miss
    @flyout_seconds   = 9.0
    @target_label     = nil
    @pip_time         = nil
    @threat_priority  = 0.0
    @standard_velocity= 2000.0
    
    @impact_lla       = impact_lla      if impact_lla
    @launch_time      = launch_time     if launch_time
    @flyout_seconds   = flyout_seconds  if flyout_seconds
    
    @dynamic_trajectory = nil
    @trajectory         = Array.new

  debug_me{[:@label, :@flyout_seconds]}  if $debug

  end

  #############################################
  ## Over-ride methods in Missile Class added by
  ## the predict_trajectory module
  def load_trajectory(my_name=@label)
    @traj_filename = "traj data generated dynamically not by file"
    
    @dynamic_trajectory = InterceptorGenerator.new(
        @launch_lla,
        @impact_lla,
        {
          :flight_time      => @flyout_seconds, # (seconds) if given, constains the trajectory to this specific TOF
          :launch_time      => @launch_time     # Seconds from the beginning of the simulation when the object will start flying
        }
      )
    
    @launch_time  = $sim_time.start_time + @launch_time
    @impact_time  = @launch_time + @flyout_seconds
    @life_span    = ( @launch_time .. @impact_time )
  
  end

  #################
  def current_state
    load_trajectory unless @traj_filename
    if @last_update_time < $sim_time.sim_time
      @trajectory << @dynamic_trajectory.state_at($sim_time.now)
      @last_update_time = $sim_time.sim_time
    end
    return @trajectory.last
  end

  ####################
  def current_position
    return current_state[0]
  end
  
  ####################
  def current_velocity
    return current_state[1]
  end
  
  ####################
  def current_attitude
    return current_state[2]
  end



  #############################################
  def get_lla
    if $sim_time.sim_time < @impact_time
      if @last_update_time < $sim_time.sim_time
        @lla = get_position_of(@sop)              # FIXME: Specific to STK
        @last_update_time = $sim_time.sim_time
      end
    else
      @state = :impacted
    end
  end




  ################################################
  def ready(target)
    log_this "... ready"
    @target           = target
    @target_label     = target.label
    @state            = :ready
        
    target.engaged_by[@label] = $sim_time.sim_time

  end
  
  #################################################
  ## FIXME:  The set method is screwy.  This functionality should
  ##         be in the Launcher object.
  def set
    log_this "... set"
    
    target_lla = nil

    pa = @target.predict_trajectory   # pa is array with [0] at now
    
    # QUESTION: What time frame is @pip_time?
    
    pip_offset = Integer(@pip_time - $sim_time.start_time) # IMPLIES: @pip_time is time object in the sim time frame
    
#    pip_offset += 1 # why ??
#    @pip_time   = $sim_time.start_time + pip_offset # isn't this the same as @pip_time + 1 ??
    
    pa_inx = pip_offset - $sim_time.offset
    
    debug_offset  = 5
    debug_first   = pa_inx - debug_offset
    debug_last    = pa_inx + debug_offset
    debug_range   = (debug_first..debug_last)
    debug_pa      = pa[debug_range]
    
    target_lla = pa[pa_inx]
    
    if target_lla.nil?
      debug_me("NIL-TARGET_LLA"){[:pip_offset, :$sim_time, :pa_inx, "pa.length", :debug_offset, :debug_range, :debug_pa]}
    else
      debug_me "========== #{@target_label} #{pip_offset} #{target_lla.join(', ')} =============="  if $debug    
    end
    

    
    @impact_lla   = target_lla

  debug_me{[:@label, :@flyout_seconds]}  if $debug

    @launch_time  = @pip_time - @flyout_seconds   ## std fos was over-riden in launch_against
    launch_time_offset = ( @launch_time - $sim_time.start_time ).to_i

   
    @engagement_result = :hit
    if @pk < rand(101)
      @launch_time += @miss_factor 
      @engagement_result = :miss
      launch_time_offset += @miss_factor     # on a miss the launch is done late
    end

    @impact_time = @pip_time
    
    

    
     @state  = :set
    
  end ## end of def set
  
  #################################################
  def engage
    log_this "... engage .... result will be a #{@engagement_result}"
    
    wui = WarmUpInterceptor.new
    
    wui.time_               = $sim_time.now

    wui.launch_time_        = @launch_time - $sim_time.start_time   # convert to relative time
    wui.flight_time_        = @flyout_seconds
    wui.launch_lla_         = @launch_lla.to_a
    wui.impact_lla_         = @impact_lla.to_a

    wui.interceptor_label_  = @label
    wui.launcher_label_     = @launcher_label
    wui.threat_label_       = @target_label
    wui.engagement_result_  = @engagement_result.to_s
    
    wui.publish

  end ## end of def engage
  
  ############################
  def launch_against(a_target, from_launcher_label, pip_time, flyout_seconds=nil)
    log_this "#{@label} is being launched against #{a_target.label}"
    @pip_time       = pip_time
    @flyout_seconds = flyout_seconds  unless flyout_seconds.nil? # over-ride default with given


debug_me{[:@label, :@flyout_seconds]}  if $debug

#    begin
      ready(a_target)
      set
      engage
#    rescue
#      @state = :mis_fire
#    end
    
    @engagement_result  = :miss if :mis_fire == @state    
    @launcher_label      = from_launcher_label
    

    $interceptor_labels = Array.new if $interceptor_labels.nil?
    
    unless $interceptor_labels.include?(@label)
      $interceptor_labels << @label
    end

  end  ## end of def launch_against

  ###############
  def send_to_stk
  
    @sop = create_missile( 
                    @label,
                    @launch_lla, 
                    @impact_lla, 
                    @launch_time, 
                    @trajectory_shaper,
                    $BLUE_STK_COLOR,  # color
                    0.5,              # scale
                    @model)
    
    
    
    unless @sop
      a_str = "STK did not create an interceptor object for #{label}"
      log_this a_str
      raise a_str
    end
    
    # Add explosion sequence

    if :hit == @engagement_result
      add_stk_explosion(@sop, @pip_time)  
      target_sop = @target_label.is_missile? ? "*/Missile/#{@target_label}" : "*/Aircraft/#{@target_label}"
      add_stk_explosion(target_sop, @pip_time)
      
      $unload_at = SharedMemCache.get('unload_at')
      $unload_at << [@sop,       pip_time]
      $unload_at << [target_sop, pip_time + 2]    ## 2 seconds take the target off the screen
      SharedMemCache.set('unload_at', $unload_at)
      
    end

  end

  #################
  def self_destruct
  
    log_this "Sending self_destruct message to #{@label}"
    
    we_blew_it = false
  
    #TODO: replace hardcoded '3' with something from FP:comms_latency
    if ($sim_time.sim_time + 3) < @impact_time

      if :hit == @engagement_result
        target_sop = @target_label.is_missile? ? "*/Missile/#{@target_label}" : "*/Aircraft/#{@target_label}"
        delete_stk_explosion(target_sop,    @pip_time)      
        worked = remove_from_unload_at( [target_sop, @pip_time + 2] )    ## 2 seconds take the target off the screen
        log_this("Result from remove_from_unload_at: #{worked}")
      end

      $interceptor_terminated.record_event(@label, "self_destruct successful")
      
      $unload_at = SharedMemCache.get('unload_at')
      $unload_at << [@sop, $sim_time.sim_time + 3]
      SharedMemCache.set('unload_at', $unload_at)
      
      @state = :self_destruct
      @engagement_result = :miss
      update_cache
      log_this "... self_destruct message was received."
      t = SharedMemCache.get @target_label
      t.engaged_by.delete(@label)
      t.update_cache
      we_blew_it = true
      
      add_stk_explosion(@sop, $sim_time.sim_time + 3)
      
    else
      log_this "... too late, self_destruct not received."
    end
    
    return we_blew_it
    
  end ## end of def self_destruct
  
  ###########################
  def name
    self.class.to_s
  end

end  ## end of class Interceptor


################################################################
class Pac3 < Interceptor

  def initialize(launch_lla)
    super(self.name, launch_lla)

    @flyout_seconds     = 18.0
    @trajectory_shaper  = "TOF #{flyout_seconds}"
    @standard_velocity  = 2000.0
  end

end  ## end of class Pac3


################################################################
class Thaad < Interceptor

  def initialize(launch_lla)
    super(self.name, launch_lla)

    @flyout_seconds     = 60.0
    @trajectory_shaper  = "TOF #{flyout_seconds}"
    @standard_velocity  = 2800.0
  end
  
end  ## end of class Thaad


################################################################
class Gemt < Interceptor

  def initialize(launch_lla)
    super(self.name, launch_lla)

    @flyout_seconds     = 30.0
    @trajectory_shaper  = "TOF #{flyout_seconds}"
    @standard_velocity  = 2000.0
  end

end  ## end of class GemT



################################################################
## Sea-based Missile (SM)
class Sm < Interceptor

  def initialize(launch_lla)
    super(self.name, launch_lla)

    @flyout_seconds     = 15.0
    @trajectory_shaper  = "TOF #{flyout_seconds}"
    @standard_velocity  = 1000.0
  end

end  ## end of class Sm2


#######################
class Sm1 < Interceptor

  def initialize(launch_lla)
    super(self.name, launch_lla)

    @flyout_seconds     = 15.0
    @trajectory_shaper  = "TOF #{flyout_seconds}"
    @standard_velocity  = 1500.0
  end

end  ## end of class Sm2


#######################
class Sm2 < Interceptor

  def initialize(launch_lla)
    super(self.name, launch_lla)

    @flyout_seconds     = 15.0
    @trajectory_shaper  = "TOF #{flyout_seconds}"
    @standard_velocity  = 2000.0
  end

end  ## end of class Sm2


#######################
class Sm3 < Interceptor

  def initialize(launch_lla)
  
debug_me{[:@label, :@flyout_seconds]}  if $debug
  
    super(self.name, launch_lla)

debug_me{[:@label, :@flyout_seconds]}  if $debug

    @flyout_seconds     = 15.0
    @trajectory_shaper  = "TOF #{flyout_seconds}"
    @standard_velocity  = 2500.0

debug_me{[:@label, :@flyout_seconds]}  if $debug


  end
  
end  ## end of class Sm3


################################################################
## Short-Range (Shorad) is a generic term.  Expect many different
## instances of the class, each with different velocities.  The Pk
## tables will typical be a hemi-sphere or semi-sphere with a limited
## range.  The Pk values will be continious through-out the engagement
## zone.
class Shorad < Interceptor

  def initialize(launch_lla)
    super(self.name, launch_lla)

    @flyout_seconds     = 9.0
    @trajectory_shaper  = "TOF #{flyout_seconds}"
    @standard_velocity  = 1000.0
  end

end


###########################
class Shorad1 < Interceptor

  def initialize(launch_lla)
    super(self.name, launch_lla)

    @flyout_seconds     = 9.0
    @trajectory_shaper  = "TOF #{flyout_seconds}"
    @standard_velocity  = 1500.0
  end

end


###########################
class Shorad2 < Interceptor

  def initialize(launch_lla)
    super(self.name, launch_lla)

    @flyout_seconds     = 9.0
    @trajectory_shaper  = "TOF #{flyout_seconds}"
    @standard_velocity  = 2000.0
  end
  
end


###########################
class Shorad3 < Interceptor

  def initialize(launch_lla)
    super(self.name, launch_lla)

    @flyout_seconds     = 9.0
    @trajectory_shaper  = "TOF #{flyout_seconds}"
    @standard_velocity  = 2500.0
  end

end  ## end of class Shorad




