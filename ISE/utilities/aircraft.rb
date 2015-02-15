######################################################
###
##  File:  Aircraft.rb
##  Desc:  Generic Aircraft Class
#

require 'LlaCoordinate'
require 'StkMessage'
require 'observer'
require 'predict_trajectory'

################################################################
class Aircraft
  
  attr_accessor :label
  attr_accessor :type
  attr_accessor :unit_id
  attr_accessor :track_id         # Used by Link-16 messages
  attr_accessor :sop              # STK Object Path
    
  attr_accessor :launch_lla
  attr_accessor :launch_time
  attr_accessor :launch_area_label
  
  
  attr_accessor :lla              # last known position
  attr_accessor :last_update_time # Last time the lla was updated
  
  attr_accessor :impact_lla
  attr_accessor :impact_time
  attr_accessor :threat_to        # An array of Defended Area labels to which this Aircraft is a threat
  attr_accessor :cep              # radius of effects in meters
    
  attr_accessor :state

  attr_accessor :stk_color        # The color to use to designate this object within STK
  attr_accessor :flight_plan

  attr_accessor :threat_priority

  attr_accessor :detected_by      # Hash keyed on Radar label; value is Array [first_contact_time, most_recent_contact_time]

  attr_accessor :engaged_by    # hash of Interceptor objects  

  attr_accessor :effects_radius # effects radius for threats (defaults to zero for non-threats)

  attr_accessor :radar_detects_before_warning   # an emulation of sensitivity to radar
    
  include Observable
  include Trajectory
  
  def initialize( label=nil, flight_plan=nil, launch_time=$sim_time.start_time)

    if label
      @label     = label
      columns   = label.split('_')

      throw "label does not meet conventions: #{label}" unless 2 == columns.length
      
      @unit_id  = columns[1]

      @track_id = @label[0,2] + @unit_id

      @type     = @label[2,columns[0].length-2]  # drop the 'RM' from the front of the label

      threat_data = MpThreat.find_by_name(@type.downcase)
      unless threat_data.nil?
        @effects_radius = threat_data.effects_radius  # calls effects radius from mp gui (in kilometers)
      else
        @effects_radius = 0.0
      end
      
    else

      next_unit_id  = get_next_unit_id
      @unit_id      = sprintf("%03o", next_unit_id) 
      @label        = "YAUnknown_" + @unit_id
      @type         = 'Unknown'
      @track_id     = @label[0,2] + @unit_id
      @stk_color    = $YELLOW_STK_COLOR
    
    end
  
    @launch_time  = launch_time
    @impact_time  = $sim_time.end_time
    
    if 'Array' == flight_plan.class.to_s
      @launch_lla   = LlaCoordinate.new flight_plan.first[0,3]
      @impact_lla   = LlaCoordinate.new flight_plan.last[0,3]
    else
      # FIXME: If its a *.e file need to get the start and end points
      @launch_lla   = LlaCoordinate.new
      @impact_lla   = LlaCoordinate.new
    end
    
    @launch_area_label = nil
    
    @flight_plan = flight_plan
    
    @lla = LlaCoordinate.new
    
    @radar_detects_before_warning = 0   # Used by RadarFarmModel
    
    @traj_filename = nil         # Used by the predict_trajectory method
    @trajectory    = Array.new
   
    # NOTE: auto load the trajectory file to red-force missiles
    #       blue force missiles are by definition interceptors.  Their
    #       trajectory will be computered dynamically durning their launch sequence.
    load_trajectory(@label) if methods.include?('load_trajectory') # && @label.is_red_force?

    
    reset
    
  end

  
  ####################
  def range_to(thing)
    lla = thing if 'LlaCoordinate' == thing.class.to_s
    lla = thing.lla unless lla
    return @lla.distance_to(lla, :units => :kilo) * 1000.0
  end

  ####################
  def azimuth_to(thing)
    lla = thing if 'LlaCoordinate' == thing.class.to_s
    lla = thing.lla unless lla
    return @lla.heading_to(lla)
  end




  
  ###########################
  def send_to_stk(wait=false)
    @sop = create_aircraft( @label, @flight_plan, @stk_color )

    time_period = get_time_period(@sop, wait)
    
    log_this "WARNING: Could not get time period of #{@label} from STK" if time_period.empty?

    log_this "WARNING: LT: #{@launch_time} and TP0: #{time_period[0]} expected to be the same." unless @launch_time == time_period[0]
    
    @impact_time = time_period[1] unless time_period.empty?
    
    return @sop
  end


=begin
  #############################################
  ## get_lla is called from update_cache
  def get_lla
  
    if $sim_time.sim_time < @impact_time
      if @last_update_time < $sim_time.sim_time
        current_lla = get_position_of(@sop)
        
        if current_lla
          @lla = current_lla
          @last_update_time = $sim_time.sim_time
        end
        
        if :active == @state
          @engaged_by.each_key do |key|
            interceptor = SharedMemCache.get(key)
            if interceptor
              if :hit == interceptor.engagement_result
                if $sim_time.sim_time >= interceptor.pip_time
                  @state = :intercepted
                  log_this "EVENT: Confirmed intercept of #{@label} by #{interceptor.label} at #{interceptor.pip_time}"
                end
              end
            end
          end ## end pf @engaged_by.each_key do |key|
        end ## end of if :active == @state
        
      end
    else
      log_this "EVENT: Confirmed impact of #{@label} at #{@impact_lla.join(', ')} within #{@threat_to} at #{@impact_time}"
      @state = :impacted
    end
    
  end ## end of def get_lla
=end
  
  
  #########
  def reset
    @last_update_time = @launch_time
    @detected_by      = Hash.new
    @engaged_by       = Hash.new
    @threat_to        = []
    @threat_priority  = 1.0
  end


end ## end of class Aircraft



###########################################################################################
class HostileAircraft < Aircraft



  def initialize( flight_plan=nil, launch_time=Time.now )
    super(flight_plan, launch_time, false)
    @label[0,1]  = 'R'
    @track_id   = @label[0,2] + @unit_id
    @stk_color  = $RED_STK_COLOR
    @cep        = 100 unless @cep
  end

end ## end of class HostileAircraft


###########################################################################################
class FriendlyAircraft < Aircraft

  def initialize( flight_plan=nil, launch_time=Time.now )
    super(flight_plan, launch_time, false)
    @label[0,1]        = 'B'
    @track_id         = @label[0,2] + @unit_id
    @stk_color        = $BLUE_STK_COLOR
    @cep              = 100 unless @cep
    @threat_priority  = 0.0
  end

end ## end of class FriendlyAircraft


###########################################################################################
## The Bad Guys ##
##################


#####################################
## TODO: Create a Naval class
##       until then treat cargo ships like aircraft
class Cargoship < HostileAircraft
end


#####################################
## Cruise Missile
class CM < HostileAircraft

  ##############
  def initialize( flight_plan=nil, launch_time=$sim_time.start_time )
    @cep = 600
    super
  end

  ###########################
  def send_to_stk(wait=false)
    @sop = create_cruise_missile( @label, @flight_plan, @stk_color )
    
    time_period = get_time_period(@sop, wait)
    
    log_this "WARNING: Could not get time period of #{@label} from STK" if time_period.empty?

    log_this "WARNING: LT: #{@launch_time} and TP0: #{time_period[0]} expected to be the same." unless @launch_time == time_period[0]
    
    @impact_time = time_period[1] unless time_period.empty?
    
    return @sop
  end

end ## end of class CM



#####################################
## Hyper-velocity Cruise Missile
class Hypervelocity < HostileAircraft

  ##############
  def initialize( flight_plan=nil, launch_time=$sim_time.start_time )
    @cep = 600
    super
  end

  ###########################
  def send_to_stk(wait=false)
    @sop = create_cruise_missile( @label, @flight_plan, @stk_color )
    
    time_period = get_time_period(@sop, wait)
    
    log_this "WARNING: Could not get time period of #{@label} from STK" if time_period.empty?

    log_this "WARNING: LT: #{@launch_time} and TP0: #{time_period[0]} expected to be the same." unless @launch_time == time_period[0]
    
    @impact_time = time_period[1] unless time_period.empty?
    
    return @sop
  end

end ## end of class HV

###########################
class HV < Hypervelocity
end


###########################
## Generic Fixed-wing Aircraft
class Fwac < HostileAircraft
end


###########################
class Mig < HostileAircraft
end


#############################
class Mig23 < HostileAircraft
end


#############################
class Mig26 < HostileAircraft
end


###########################
class F15 < HostileAircraft
end


###########################
class F18 < HostileAircraft
end





###########################################################################################
## The Good Guys ##
###################



##############################
class AWACS < FriendlyAircraft

  def send_to_stk(wait=false)
    @sop = create_awacs( @label,
                  @flight_plan,
                  @stk_color,
                  1,    # scale
                  'AWACS\e-3a_sentry_awacs.mdl')
                  
    time_period = get_time_period(@sop, wait)
    
    log_this "WARNING: Could not get time period of #{@label} from STK" if time_period.empty?

    log_this "WARNING: LT: #{@launch_time} and TP0: #{time_period[0]} expected to be the same." unless @launch_time == time_period[0]
    
    @impact_time = time_period[1] unless time_period.empty?
    
    return @sop
  end

end


############################
class C5 < FriendlyAircraft
end

############################
class C17 < FriendlyAircraft
end

############################
class C130 < FriendlyAircraft
end


############################
class F16 < FriendlyAircraft
end


############################
class F22 < FriendlyAircraft
end ## end of class F22


############################
class F35 < FriendlyAircraft
end


###################################
class Helicopter < FriendlyAircraft
end


############################
class UAV < FriendlyAircraft
end




