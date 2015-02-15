#############################################################
###
##  File:  Thaad.rb
##  Desc:  Generic Thaad Launcher Class
#

#############################################################
# A launcher that only has Thaad intecptors.
class ThaadLauncher < Launcher

  def initialize(label, lla)
    super

    @standard_rounds  = 4


    @mode             = :shoot_look_shoot
    @flyout_seconds   = 45

    @standard_pk_air     = 0
    @standard_pk_space   = 95
    @standard_interceptor_velocity = 2800.0   # meters per second

    reset
    
  end


  ###########################################
  # Create a new Thaad interceptor instance
  def ready_a_round
    super
    return Thaad.new(@lla)
  end

end  ## end of class ThaadLauncher
