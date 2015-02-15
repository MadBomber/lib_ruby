#############################################################
###
##  File:  Gemt.rb
##  Desc:  Generic Gemt Launcher Class
#

#############################################################
# A launcher that only has GemT interceptors.
class GemtLauncher < Launcher
  def initialize(label, lla)
    super

    @standard_rounds  = 6

    @mode             = :shoot_shoot
    @flyout_seconds   = 15

    @standard_pk_air     = 85
    @standard_pk_space   = 60

    @standard_interceptor_velocity = 2000.0   # meters per second


    reset

  end

  ###########################################
  # Create a new instance of a GemT interceptor.
  def ready_a_round
    super
    return Gemt.new(@lla)
  end

end  ## end of class GemTLauncher

