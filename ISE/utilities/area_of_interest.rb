######################################################
###
##  File:  AreaOfInterest.rb
##  Desc:  Generic Area Class
##
##  Naming convention established by AAD for allowing the
##  user to define the "value" of an area:
##      NN_xxxx
##  Where NN is a numeric value for the area.  The bigger the number, the
##  more valuable the area.   The xxxx can be anything.  Labels that
##  do not meet this convention will have a value of zero.
#

require 'LlaCoordinate'
require 'PolygonArea'
require 'CircleArea'

class AreaOfInterest

  attr_accessor :label        # The unique string by which we know this AOI
  attr_accessor :area         # An area that inscribes the AreaOfInterest
  attr_accessor :color        # color used to draw geometry on map
  attr_accessor :lla          # center of mass of the area
  attr_accessor :value        # Intrenstic value of this defended area
  attr_accessor :sop          # STK Object Path

  include Observable

  
  ###########################################
  def initialize(label)
    @label  = label
    
    @value = label.split("_")[0].to_i   # naming convention: NN_xxxxxx....
    
    @area   = nil
    @color  = nil
    @lla    = nil
    @sop    = nil
  end


  #################################################################
  def value
    return @value
  end ## end of def value

=begin
  ###############
  def send_to_stk
    @sop = area_target_circle(@label, @lla, @color, @range)
    return @sop
  end
=end  
  
  #########
  def reset
    # NO-OP
  end

end ## end of class AreaOfInterest




################################################################################
class LaunchArea < AreaOfInterest

  ###########################################
  def initialize(label)

    super
    
    @color = $RED_STK_COLOR
    
# TODO: value has to come from AADSE TEWA database
    


  end

  ##########################
  def source_of_launch?(target)
    log_this("#{@label} is considering wither it is the source of #{target.label}")
    return  @area.includes?(target.launch_lla)
  end

end ## end of class LaunchArea < AreaOfInterest 


#############################################################################
class DefendedArea < AreaOfInterest

  attr_accessor :toc          # TOC assigned to protect this defended area
  
  ###########################################
  def initialize(label)

    super
    
    @color = $BLUE_STK_COLOR
    @toc   = nil

  end

  ##########################
  def threatened_by?(target)
    log_this("#{@label} is considering wither it is threatened by #{target.label}")
    return  @area.includes?(target.impact_lla)
  end
  
  ###################
  # This method is in support of multiple TOCs associated with a defended area
#  def attach_toc(toc)
#    die "Not Toc class" unless "Toc" == toc.class.to_s
#    @tocs << toc
#  end
  
  ##################################
  def auto_engage(target)
    @toc.auto_engage(target)
  end ## end of def auto_engage(target)
  
  #######################
  def can_engage?(target)
    @toc.can_engage?(target)
  end
  
end ## end of class DefendedArea < AreaOfInterest

