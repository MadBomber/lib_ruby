##############################################################
###
##  File: SimStatus.rb
##  Desc: methods to control the STK simulation
#

require 'observer'

class SimStatus

  include Observable
  
  attr_reader :status
  
  def initialize
    @status = initializing
  end
  
  ##########
  def paused
    change_status
  end
  
  def paused?
    query_status
  end

  ###########
  def running
    change_status
  end
  
  def running?
    query_status
  end
  
  ################
  def initializing
    change_status
  end
  
  def initializing?
    query_status
  end
  
  ##########
  def loaded
    change_status
  end

  def loaded?
    query_status
  end

  #################
  def change_status
    to_what = caller[0].split.last
    to_what = to_what[1,to_what.length-2]
    unless @status == to_what
      @status = to_what
      changed
      notify_observers('sim_status', self)
    end
    return @status
  end

  ################
  def query_status
    to_what = caller[0].split.last
    to_what = to_what[1,to_what.length-3]
    return @status == to_what
  end


  ########
  def to_s
    @status
  end
  

end ## end of class SimStatus


