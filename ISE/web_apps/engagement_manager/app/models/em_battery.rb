################################################################################
###
##  File:  em_battery.rb
##  desc:  A Battery is composed of one or more launchers
##
##  TODO: Link this model into the rest of the application, update
##        the other models to support the global data store.
#

class EmBattery

  # A string by which the battery is uniquely known
  attr_accessor :label
  
  # An array of strings; the labels of the launchers that
  # are attached to this battery
  attr_accessor :launchers
  
  # A cound of the total inceptors/rounds/rocks available
  # to this battery.  A sum of all launcher's rounds_available
  attr_accessor :rounds_available

 
  #####################################
  ## Create a new instance of a battery
  def initialize(label)
    @label            = label
    @launchers        = Array.new   # An array of launcher labels
    @rounds_available = 0
  end
  
  
  ##################################################
  ## Attach a launcher to this battery
  ## Add its rounds_available to the battery total
  def attach_launcher(thing)
  
    case launcher_label.class.to_s
      when 'Sting' then
        launcher_label  = thing
      when 'EmLauncher' then
        launcher_label  = thing.label
      else
        debug_me("ERROR: Expecting String or EmLauncher; got this"){:thing}
        return nil
    end
    
    unless @launchers.include? launcher_label
      @launchers << launcher_label
      @rounds_available += $em_launchers[launcher_label].rounds_available
    end
    
    return nil
    
  end ## end of def attach_launcher
  
  
  ##################################################
  ## recalculate the rounds available to a batter
  def recalculate_rounds_available
    @rounds_available = 0
    @launchers.each do |launcher_label|
      @rounds_available += $em_launchers[launcher_label].rounds_available
    end
  end

end ## class EmBattery
