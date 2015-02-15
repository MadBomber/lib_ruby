class FeArea < ActiveRecord::Base
  # database connection used by external applications
  self.establish_connection $FORCE_EFFECTIVENESS_CONFIG
  
  validates_presence_of :fe_run_id, :label, :category
  
  validates_uniqueness_of :label, :scope => :fe_run_id
  
  belongs_to :fe_run
  
  has_many :incoming_threats, :class_name => 'FeThreat', :foreign_key => :target_area_id
  has_many :launched_threats, :class_name => 'FeThreat', :foreign_key => :source_area_id 
  
  # find all from run
  named_scope :run, lambda { |*args| { :conditions => {:fe_run_id => args.first || FeRun.last.id} } }
    
  named_scope :sources,  :conditions => {:category => 'source'}
  named_scope :targets, :conditions => {:category => 'target'} 
end
