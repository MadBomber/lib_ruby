################################################################
###
##  File:  Missile.rb
##  Desc:  Generic Missile Class
#

require 'aadse_utilities'
require 'predict_trajectory'


################################################################
class Missile
  
  attr_accessor :label            # Fully qualified label like: RMMRBM_123
  attr_accessor :type             # like characters after the 'RM' before the '_'
  attr_accessor :unit_id          # characters after the '_'
  attr_accessor :track_id         # Used by the Link-16 Messages.  Like: RM123
  attr_accessor :sop              # STK Object Path
  
  attr_accessor :state            # descriptive symbol )set to :active by loop_closer#push_target_data
  attr_accessor :cep              # effect radius in meters

  attr_accessor :launch_lla
  attr_accessor :launch_time
  attr_accessor :launch_area_label # label of the Launch Area of Interest
    
  attr_accessor :lla              # last known position
  attr_accessor :last_update_time # Last time lla was updated
  
  attr_accessor :impact_lla
  attr_accessor :impact_time
  attr_accessor :threat_to        # An array of labels of the object (DefendedArea, Missile) to which this missile is a threat
  attr_accessor :threat_priority

  attr_accessor :trajectory_shaper  # Used with STK to form the trajectory
  attr_accessor :apogee_min         # meters
  
  attr_accessor :detected_by      # Hash keyed on Radar label; value is Array [first_contact_time, most_recent_contact_time]

  attr_accessor :engaged_by    # hash keyed on Interceptor label with value of time the engagement was established

  attr_accessor :effects_radius # effects radius for threats (defaults to zero for non-threats)

  attr_accessor :radar_detects_before_warning   # an emulation of sensitivity to radar
  
  
  include Observable
  include Trajectory
  
  def initialize(label=nil, launch_lla=nil )  # track_id has a naming convention

  debug_me{[:@label, :@flyout_seconds]}   if $debug
    
    if label
      @label     = label
      columns   = label.split('_')

      throw "label does not meet conventions: #{label}" unless 2 == columns.length
      
      @unit_id  = columns[1]

      @track_id = @label[0,2] + @unit_id

      @type     = @label[2,columns[0].length-2]  # drop the 'RM' from the front of the label

      @effects_radius = 0.125   # defaulted to 125 meters

      
    else

      next_unit_id  = get_next_unit_id
      @unit_id      = sprintf("%03o", next_unit_id) 
      @label        = "RMUnknown_" + @unit_id
      @type         = 'Unknown'
      @track_id     = @label[0,2] + @unit_id
      @effects_radius = 0.0
    
    end
    
    
    @launch_lla       = launch_lla
    @launch_area_label = nil
    
    
    @lla        = LlaCoordinate.new
    @impact_lla = LlaCoordinate.new
    
    @trajectory_shaper = ""
    
    @traj_filename  = nil         # Used by the predict_trajectory method
    @trajectory     = Array.new
    
    @launch_time  = nil
    @impact_time  = nil
    
    @state  = :created
    @sop    = nil
    
    @apogee_min = 25000.0
    @cep        = 600
    
    @radar_detects_before_warning = 0   # Used by RadarFarmModel
    

    
    # NOTE: auto load the trajectory file to red-force missiles
    #       blue force missiles are by definition interceptors.  Their
    #       trajectory will be computered dynamically durning their launch sequence.
    load_trajectory(@label) if methods.include?('load_trajectory') && @label.is_red_force?




    reset

  debug_me{[:@label, :@flyout_seconds]}  if $debug


  end ## end of def initialize(launch_lla)

  #############################################
  ## get_lla is called from update_cache
  def get_lla
  
    if $sim_time.sim_time < @impact_time
      if @last_update_time < $sim_time.sim_time
        @lla = get_position_of(@sop)
        @last_update_time = $sim_time.sim_time
        
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


  #################################################
  # TODO: flesh out destruct method
  def destruct
    @state  = :destruct
    update_cache
  end
  
  #################################################
  def send_to_stk(wait=false)
    @sop = create_missile(@label, @launch_lla, @impact_lla, @launch_time, @trajectory_shaper)
    
    log_this "DEBUG sop: #{@sop}"
    
    time_period = get_time_period(@sop, wait)
    
    log_this "WARNING: Could not get time period of #{@label} from STK" if time_period.empty?

    log_this "WARNING: LT: #{@launch_time} and TP0: #{time_period[0]} expected to be the same." unless @launch_time == time_period[0]
    
    @impact_time = time_period[1] unless time_period.empty?
       
    update_cache
    return @sop
  end
  
  ################################################
  def reset
    @state            = :created
    @detected_by      = Hash.new
    @engaged_by       = Hash.new
    @last_update_time = $sim_time.start_time
    @threat_to        = []
    @threat_priority  = 1.0
  end
  
end  ## end of class Missile
