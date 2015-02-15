class FeLauncher < ActiveRecord::Base
  # database connection used by external applications
  self.establish_connection $FORCE_EFFECTIVENESS_CONFIG
  
  validates_presence_of :fe_run_id, :label, :category
  
  validates_uniqueness_of :label, :scope => :fe_run_id
  
  belongs_to :fe_run
  
  has_many :fe_engagements
  
  has_many :fe_interceptors, :through => :fe_engagements
  has_many :fe_threats,      :through => :fe_engagements
  
  #TODO: Consider adding launcher status
  
  # find all from run
  named_scope :run, lambda { |*args| { :conditions => {:fe_run_id => args.first || FeRun.last.id} } }
end
