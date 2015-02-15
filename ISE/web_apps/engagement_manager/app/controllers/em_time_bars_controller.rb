class EmTimeBarsController < ApplicationController
  
  cattr_accessor :total_bar_width
  
  #########
  def index
  end ## def index

  ########
  def show
  end ## def show

  ##############################################################################
  ##                             General Methods                              ##
  ##############################################################################

  def self.set_current_duration
    em_threat = EmThreatsController.get_current_threat
    
    $em_current_time_bar_duration = em_threat.impact_time - $sim_time.now 
  end
  
  def self.get_current_duration
    return $em_current_time_bar_duration
  end

  ########################
  def self.earliest_launch_time
    earliest_launch_time = $sim_time.duration

    @@current_threat.launchers.each do |launcher|
      if launcher.first_launch_time < earliest_launch_time
        earliest_launch_time = launcher.first_launch_time
      end
    end ## @@current_threat.launchers.each do |launcher|

    return earliest_launch_time
  end ## def earliest_launch_time
  
end ## class EmTimeBarsController < ApplicationController
