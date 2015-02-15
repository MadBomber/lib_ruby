######################################################
###
##  File:  Target.rb
##  Desc:  Target Class and principle subclasses
#


################################################################
class Target < Missile

  def initialize(launch_lla, impact_lla, launch_time=$sim_time.start_time)
    super(launch_lla)
    @type         = self.class.to_s
    @name         = 'R' + @name
    @name         = @name + @type + '_' + @unit_id
    @track_id     = @name[0,2] + @unit_id
    @impact_lla   = impact_lla
    @launch_time  = launch_time
    @apogee_min   = 25000
    @trajectory_shaper  = "ApogeeAlt #{@apogee_min+rand(5000)}"

#    update_cache   
  end

end  ## end of class Missile

################################################################
class ICBM < Target
  def initialize(launch_lla, impact_lla, launch_time=Time.now)
    super
    @apogee_min         = 55000
    @trajectory_shaper  = "ApogeeAlt #{@apogee_min+rand(5000)}"
    @cep                = 1600
    update_cache
  end

end  ## end of class ICBM

################################################################
class LRBM < Target
  def initialize(launch_lla, impact_lla, launch_time=Time.now)
    super
    @apogee_min         = 45000
    @trajectory_shaper  = "ApogeeAlt #{@apogee_min+rand(5000)}"
    @cep                = 1600
    update_cache
  end

end  ## end of class LRBM


################################################################
class MRBM < Target
  def initialize(launch_lla, impact_lla, launch_time=Time.now)
    super
    @apogee_min         = 35000
    @trajectory_shaper  = "ApogeeAlt #{@apogee_min+rand(5000)}"
    @cep                = 1000
    update_cache
  end

end  ## end of class MRBM

################################################################
class SRBM < Target
  def initialize(launch_lla, impact_lla, launch_time=Time.now)
    super
    @apogee_min         = 25000
    @trajectory_shaper  = "ApogeeAlt #{@apogee_min+rand(5000)}"
    @cep                = 600
    update_cache
  end

end  ## end of class SRBM

