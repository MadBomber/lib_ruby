#############################################################
###
##  File:  SeabasedMissileLauncher.rb
##  Desc:  Launchers that only have Sea-based Missiles (sm) interceptors.

require 'Launcher'

class SmLauncher < Launcher
  def initialize(label, lla)
    super

    ## Defaults
    @standard_rounds                = 6
    @mode                           = :shoot_shoot
    @flyout_seconds                 = 15
    @standard_pk_air                = 85
    @standard_pk_space              = 60
    @standard_interceptor_velocity  = 1000.0   # meters per second

    reset

  end

  ###########################################
  # Create a new instance of a GemT interceptor.
  def ready_a_round
    super
    return Sm.new(@lla)
  end

end  ## end of class SmLauncher





########################################################
## Additional sub-classes

class Sm1Launcher < Launcher
  def initialize(label, lla)
    super

    ## Defaults
    @standard_rounds                = 6
    @mode                           = :shoot_shoot
    @flyout_seconds                 = 15
    @standard_pk_air                = 85
    @standard_pk_space              = 60
    @standard_interceptor_velocity  = 1500.0   # meters per second

    reset

  end

  ###########################################
  # Create a new Sm interceptor instance
  def ready_a_round
    super
    return Sm1.new(@lla)
  end

end 

###############################################
class Sm2Launcher < Launcher
  def initialize(label, lla)
    super

    ## Defaults
    @standard_rounds                = 6
    @mode                           = :shoot_shoot
    @flyout_seconds                 = 15
    @standard_pk_air                = 85
    @standard_pk_space              = 60
    @standard_interceptor_velocity  = 2000.0   # meters per second

    reset

  end

  ###########################################
  # Create a new Sm interceptor instance
  def ready_a_round
    super
    return Sm2.new(@lla)
  end

end 


###############################################
class Sm3Launcher < Launcher
  def initialize(label, lla)
    super

    ## Defaults
    @standard_rounds                = 6
    @mode                           = :shoot_shoot
    @flyout_seconds                 = 15
    @standard_pk_air                = 85
    @standard_pk_space              = 60
    @standard_interceptor_velocity  = 2500.0   # meters per second

    reset

  end

  ###########################################
  # Create a new Sm interceptor instance
  def ready_a_round
    super
    return Sm3.new(@lla)
  end

end 




