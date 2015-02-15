class FeEngagement < ActiveRecord::Base
  # database connection used by external applications
  self.establish_connection $FORCE_EFFECTIVENESS_CONFIG
  
  validates_presence_of :fe_run_id, :fe_launcher_id, :fe_threat_id, :status
  
  validates_uniqueness_of :fe_launcher_id, :scope => [:fe_run_id, :fe_threat_id]
  
  belongs_to :fe_run
  belongs_to :fe_launcher
  belongs_to :fe_threat
  
  has_many :fe_interceptors
  
  # find all from run
  named_scope :run, lambda { |*args| { :conditions => {:fe_run_id => args.first || FeRun.last.id} } }
    
  ##### States #####
  @@STATES = ['canceled', 'engaging', 'failed', 'pending', 'succeeded']
  
  @@optimistic = true
    
  validates_inclusion_of :status, :in => @@STATES
      
  @@STATES.each do |state|
    named_scope state.to_sym, :conditions => { :status => state }
  end
  
  
  ##############################################################################
  ##                              Status Methods                              ##
  ##############################################################################
  
    
  #####################
  # Update an engagement
  def update_engagement
    case self.fe_threat.status
    ################
    when 'destroyed' then
      threat_was_destroyed
      
    ##################
    when 'flying' then
      threat_is_flying
      
    ####################
    when 'impacted' then
      threat_has_impacted
      
    ####
    else
      raise "Unexpected threat status: #{self.fe_threat.status}."
    end
    
    save
  end ## def self.update_engagement
  
  
  ##############################################################################
  ##                              Private Methods                             ##
  ##############################################################################
  private
  
  #############################
  # The threat was destroyed, update the current status
  def threat_was_destroyed
    possible_states = ['canceled', 'failed', 'pending', 'succeeded']
      
    set_proper_status(possible_states)
  end ## def self.threat_was_destroyed
  
  
  #########################
  # The threat is flying, update the current status
  def threat_is_flying
    possible_states = ['canceled', 'engaging', 'failed', 'pending']
      
    set_proper_status(possible_states)
  end ## def self.threat_is_flying
  
  
  ############################
  # The threat has impacted, update the current status
  def threat_has_impacted
    possible_states = ['canceled', 'failed', 'pending']
      
    set_proper_status(possible_states)
  end ## def self.threat_has_impacted
  
  
  ###########################################
  # Go through all possible states and set the one that matches
  #   possible_states = [all, possible, states]
  def set_proper_status(possible_states)
    possible_states.each do |state|
      if method("check_#{state}").call
        self.status = state
        return self.status
      end
    end ## possible_states.each do |state|
  end ## def self.set_proper_status(possible_states)
  
  
  #######################
  # Return true if engagement was canceled, else false
  def check_canceled
    return check_canceled_failed == 'canceled'
  end ## def self.check_canceled
  
  
  #######################
  # Return true if currently engaging, else false
  def check_engaging
    return (not self.fe_interceptors.engaging.empty?)
  end ## def self.check_engaging
  
  
  #####################
  # Return true if engagement failed, else false
  def check_failed
    return check_canceled_failed == 'failed'
  end ## def self.check_failed
  
  ##############################
  # Check whether canceled or failed.
  # 'canceled' if all interceptors were terminated
  #            or mixed and optimistic
  # 'failed'   if all interceptors missed
  #            or mixed and not optimistic
  # otherwise nil
  def check_canceled_failed
    num_ints     = self.fe_interceptors.count
    num_canceled = self.fe_interceptors.terminated.count
    num_missed   = self.fe_interceptors.missed.count
    
    state = nil
    
    if num_ints == num_canceled
      state = 'canceled'
    elsif num_ints == num_missed
      state = 'failed'
    elsif num_ints == num_canceled + num_missed
      state = @@optimistic ? 'canceled' : 'failed'
    end
    
    return state
  end ## def self.check_canceled_failed
  
  
  ######################
  # if the threat is flying
  #   return true if an interceptor hit, else false
  # if the threat is finished
  #   return true if an interceptor is engaging, else false
  def check_pending
    if self.fe_threat.flying?
      return check_succeeded
    else
      return check_engaging
    end
  end ## def self.check_pending
  
  
  ########################
  # Return true if an interceptor has hit, else false
  def check_succeeded
    return (not self.fe_interceptors.hit.empty?)
  end ## def self.check_succeeded
  
end
