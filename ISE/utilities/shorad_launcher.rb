#############################################################
###
##  File:  Shorad.rb
##  Desc:  Generic Shorad Launcher Class
#

require 'Launcher'

#############################################################
# A Launcher that only has Shorad interceptors
class ShoradLauncher < Launcher
  def initialize(label, lla)
    super

    @standard_rounds  = 10

    @mode             = :shoot
    @flyout_seconds   = 9

    @standard_pk_air     = 60
    @standard_pk_space   = 0
    
    @standard_interceptor_velocity = 2000.0   # meters per second
 
    reset
    
  end


  ###########################################
  # Creates a new instance of a Pac3 interceptor.
  def ready_a_round
    super
    return Shorad.new(@lla)
  end


end  ## end of class ShoradLauncher


########################################################
## Additional sub-classes

class Shorad1Launcher < ShoradLauncher

  ###########################################
  # Create a new Sm interceptor instance
  def ready_a_round
    super
    return Shorad1.new(@lla)
  end

end 

class Shorad2Launcher < ShoradLauncher

  ###########################################
  # Create a new Sm interceptor instance
  def ready_a_round
    super
    return Shorad2.new(@lla)
  end

end 

class Shorad3Launcher < ShoradLauncher

  ###########################################
  # Create a new Sm interceptor instance
  def ready_a_round
    super
    return Shorad3.new(@lla)
  end

end 


