class FeThreat < ActiveRecord::Base
  # database connection used by external applications
  self.establish_connection $FORCE_EFFECTIVENESS_CONFIG
  
  validates_presence_of :fe_run_id, :label, :category, :target_area_id, :status
  
  validates_uniqueness_of :label, :scope => :fe_run_id
  
  belongs_to :fe_run
  
  belongs_to :target_area, :class_name => 'FeArea', :foreign_key => :target_area_id
  belongs_to :source_area, :class_name => 'FeArea', :foreign_key => :source_area_id
  
  
  has_many :fe_engagements
  
  has_many :fe_interceptors, :through => :fe_engagements
  has_many :fe_launchers, :through => :fe_engagements
  
  named_scope :air, :conditions => [" label LIKE ? " , "RA%"]
  named_scope :space, :conditions => [" label LIKE ? " , "RM%"]
  
  
  ##### States #####
  STATES = ['destroyed', 'flying', 'impacted']
    
  validates_inclusion_of :status, :in => STATES
      
  STATES.each do |state|
    named_scope state.to_sym, :conditions => { :status => state }
  end
  
  
  # find all from run
  named_scope :run, lambda { |*args| { :conditions => {:fe_run_id => args.first || FeRun.last.id} } }
  
  
  ##############################################################################
  ##                           Status Query Methods                           ##
  ##############################################################################
    
  ##############
  def destroyed?
    return self.status == 'destroyed'
  end ## def destroyed?
  
  
  ############
  def engaged?
    return (not self.fe_interceptors.engaging.empty?)
  end ## def engaged?
  
    
  ###########
  def flying?
    return self.status == 'flying'
  end ## def flying?
  
  
  #############
  def impacted?
    return self.status == 'impacted'
  end ## def impacted?
  
  
  #############
  def finished?
    return (not flying?)
  end ## def finished?
    
end
