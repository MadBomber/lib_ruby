#############################################################
###
##  File:  Pac3.rb
##  Desc:  Generic Pac3 Launcher Class
#

#############################################################
# A Launcher that only has Pac3 interceptors
class Pac3Launcher < Launcher
  def initialize(label, lla)
    super

    @standard_rounds  = 8

    @mode             = :shoot_shoot
    @flyout_seconds   = 9

    @standard_pk_air     = 95
    @standard_pk_space   = 90
    
    @standard_interceptor_velocity = 2000.0   # meters per second
 
    reset
    
  end


  ###########################################
  # Creates a new instance of a Pac3 interceptor.
  def ready_a_round
    super
    return Pac3.new(@lla)
  end

  
end  ## end of class Pac3Launcher
