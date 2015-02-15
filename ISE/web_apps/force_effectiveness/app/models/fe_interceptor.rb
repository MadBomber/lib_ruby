class FeInterceptor < ActiveRecord::Base
  # database connection used by external applications
  self.establish_connection $FORCE_EFFECTIVENESS_CONFIG
  
  validates_presence_of :category, :fe_engagement_id, :fe_run_id, :label, :status
  
  validates_uniqueness_of :label, :scope => :fe_run_id
  
  belongs_to :fe_engagement
  belongs_to :fe_run
  has_one :fe_threat,   :through => :fe_engagement
  has_one :fe_launcher, :through => :fe_engagement
  
  
  
  ##### States #####
  STATES = ['canceled', 'destroyed', 'engaging', 'hit', 'missed']
    
  validates_inclusion_of :status, :in => STATES
      
  STATES.each do |state|
    named_scope state.to_sym, :conditions => { :status => state }
  end
  
  # These don't seem to work when called indirectly, say through the launcher or engagement.
  named_scope :engaged, :conditions => "status = 'hit' OR status = 'missed'"
  named_scope :finished, :conditions => "status != 'engaging'"
  named_scope :terminated, :conditions => "status = 'canceled' OR status = 'destroyed'"
  
  # find all interceptors from a particular engagement
  named_scope :engagement, lambda { |eng_id| { :conditions => {:fe_engagement_id => eng_id} } }
  
  # find all from run
  named_scope :run, lambda { |*args| { :conditions => {:fe_run_id => args.first || FeRun.last.id} } }
    
  ##############################################################################
  ##                           Status Query Methods                           ##
  ##############################################################################
    
  #############
  def canceled?
    return self.status == 'canceled'
  end ## def canceled?
  
  
  ##############
  def destroyed?
    return self.status == 'destroyed'
  end ## def destroyed?
  
  
  ############
  def engaged?
    engaged_statuses = ['hit', 'missed']
      
    return engaged_statuses.include?(self.status)
  end ## def engaged?
  
  
  #############
  def engaging?
    return self.status == 'engaging'
  end ## def engaging?
  
  
  #############
  def finished?
    return (not engaging?)
  end ## def finished?
  
  
  ########
  def hit?
    return self.status == 'hit'
  end ## def hit?
  
  
  ###########
  def missed?
    return self.status == 'missed'
  end ## def missed?
  
  
  ###############
  def terminated?
    terminated_statuses = ['canceled', 'destroyed']
    
    return terminated_statuses.include?(self.status)
  end ## def terminated?
  
end
