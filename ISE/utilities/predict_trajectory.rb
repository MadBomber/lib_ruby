#####################################################################
###
##  File: predict_trajectory.rb
##  Desc: Predict the trajectory of a thing
##        This is a module to be included into a thing class
##        Assumes @launch_time and @impact_time are defined by the class
#

require 'aadse_utilities'

module Trajectory

  VALID_PHASES  = [:boost, :cruise, :terminal]    # only interested in :terminal

  CRUISE_DELTA  = 50.0    # (meters) if change in altitude is greater than this, its not cruising
                          # A negative change in altitude greater than this means missile is ub
                          # terminal phase of its trajectory

  BEARING_DELTA = 5.0     # (degrees) if difference (abs) in bearing from point now to point next and
                          # from point now to impact point is less than this amount then we can
                          # conclude that an air breathing threat is on its final leg of its
                          # trajectory bearing down on its impact point.

  NORTH_DIFF    = 360.0 - BEARING_DELTA   # Moving North on final leg to impact is a special case
                                          # if the difference is greater than NORTH_DIFF then
                                          # the threat is on its final leg to impact.
                                          
  attr_accessor :traj_filename      # The Pathname of the *.traj file
  attr_accessor :trajectory         # Array of LLA points .first is the launch position; .last is the impact position
  attr_reader   :life_span          # The life span of this thing
  


  ###################
  def load_trajectory(my_name=@label)

    @traj_filename  = $TRAJ_DIR + "#{my_name.upcase}.traj"
    @launch_time    = 0
    @impact_time    = 0
    
    begin
    
      f = File.open(@traj_filename)
      
      puts "Loading trajectory file: #{@traj_filename} ..." # if $verbose or $debug
      
      f.each_line do |a_line|
        columns = a_line.split(',')
        t = columns[0].to_i
        @launch_time  = ($sim_time.start_time + t) if 0 == @launch_time

        @trajectory   << [  LlaCoordinate.new(columns[1].to_f,columns[2].to_f,columns[3].to_f), # position
                            [ columns[4].to_f,columns[5].to_f,columns[6].to_f ],                # velocity
                            [ columns[7].to_f,columns[8].to_f,columns[9].to_f ]                 # attitude
                         ]

      end

      f.close
      
    rescue
      # most likely a trajectory file does not exist
      throw "Trajectory File Does Not Exist for #{my_name}"
    end
    
    @impact_time    = @launch_time + (@trajectory.length - 1)   # FIXME: Assumes that each entry is one second, the time delta could be less than 1.0

    @launch_lla     = @trajectory.first[0]
    @impact_lla     = @trajectory.last[0]
    
    @life_span = ( @launch_time .. @impact_time )

  end ## end of def load_trajectory


  ###################################################################
  ## predict my trajectory for the next delta_seconds

  def predict_trajectory(delta_seconds=$sim_time.duration)

    log_this "entered predict_trajectory with delta_seconds: #{delta_seconds}"

    delta_seconds = Integer(delta_seconds) unless 'Fixnum' == delta_seconds.class.to_s
    


    unless @traj_filename
      log_this "traj_filename: #{@traj_filename}"
      load_trajectory 
    end


    if $sim_time.sim_time > @impact_time
      log_this "now ( #{$sim_time.sim_time} ) is after impact_time: #{@impact_time}"
      return nil 
    end

    if $sim_time.sim_time < @launch_time
      log_this "now ( #{$sim_time.sim_time} ) is before launch_time: #{@launch_time}"
      return nil
    end
    
    # The thing is current flying.  $sim_time.sim_time is after launch_time and before impact_time
    # @trajectory.first (index zero) is the launch event
    # The @trajectory array is indexed relative to the launch_time
    
    start_span  = ($sim_time.sim_time - @launch_time).to_i  # get the starting index at $sim_time.sim_time
    end_span    = (start_span + delta_seconds).to_i         # tack on the requested delta_seconds into the future
    
    log_this "initial relative (from now) time span:  #{start_span} .. #{end_span}"
    
    # if delta_seconds exceeds the time left before impact, adjust delta_seconds
    temp_d8ts   = @launch_time + end_span
    
    if temp_d8ts > @impact_time
      end_span = (@impact_time - @launch_time).to_i
    end
    
    time_span = ( start_span .. end_span )  # relative from now
    
    log_this "final relative (from now) time span: #{time_span}"
    
#    puts "returning: #{@trajectory[time_span]}"
#    puts "length of trajectory: #{@trajectory.length}"
#    puts "#{@trajectory}" 
    
    return @trajectory[time_span].map { |entry| entry[0] } # [0] is the lla for that point in time

  end ## end of def predict_trajectory

  ###################
  def predict_trajectory_absolute
    
    f = File.open(@traj_filename)

    @trajectory_absolute = Array.new
    
    f.each_line do |a_line|
      columns = a_line.split(',')
      t = columns[0].to_i
      @launch_time  = ($sim_time.start_time + t) if 0 == @launch_time

      @trajectory_absolute[t] = LlaCoordinate.new(columns[1].to_f,columns[2].to_f,columns[3].to_f) # position

    end

    f.close

    
    @impact_time    = @launch_time + (@trajectory.length - 1)   # FIXME: Assumes that each entry is one second, the time delta could be less than 1.0

    @launch_lla     = @trajectory.first[0]
    @impact_lla     = @trajectory.last[0]
    
    @life_span = ( @launch_time .. @impact_time )

    return @trajectory_absolute

  end ## end of def load_trajectory
  
  
  #####################
  def current_position
    load_trajectory unless @traj_filename
    
    return nil unless @life_span.include?($sim_time.sim_time)
    
    traj_offset = ($sim_time.sim_time - @launch_time).to_i
    
    @lla = @trajectory[traj_offset][0]

    return @lla
    
  end
  
  
  ######################
  def terminal_phase?
  
    load_trajectory unless @traj_filename
    
    return false unless @life_span.include?($sim_time.sim_time)
    return false unless @life_span.include?($sim_time.sim_time + 1.0) # do we have a next second
        
    traj_offset       = ($sim_time.sim_time - @launch_time).to_i
    traj_offset_next  = traj_offset + 1
    
    alt_now   = @trajectory[traj_offset][0].alt
    alt_next  = @trajectory[traj_offset_next][0].alt

    return false if alt_now < 0.0
    return false if alt_next < 0.0
    
    # got two positive altitudes for now and next that are 1 second apart
    
    alt_delta = alt_now - alt_next
    
    return false if alt_delta < CRUISE_DELTA

    return true

  end

  
  #####################
  def current_velocity
    load_trajectory unless @traj_filename
    
    return nil unless @life_span.include?($sim_time.sim_time)
    
    traj_offset = ($sim_time.sim_time - @launch_time).to_i
    
    return @trajectory[traj_offset][1]

  end


  
  #####################
  def current_attitude
    load_trajectory unless @traj_filename
        
    return nil unless @life_span.include?($sim_time.sim_time)
    
    traj_offset = ($sim_time.sim_time - @launch_time).to_i
    
    return @trajectory[traj_offset][2]

  end



end  ## end of module Trajectory
