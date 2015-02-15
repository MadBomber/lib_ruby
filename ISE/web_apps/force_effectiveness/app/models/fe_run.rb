class FeRun < ActiveRecord::Base
  # database connection used by external applications
  self.establish_connection $FORCE_EFFECTIVENESS_CONFIG
  self.establish_connection $MISSON_PLANNING_CONFIG
  
  validates_uniqueness_of :id
  
  has_many :fe_areas,        :dependent => :destroy
  has_many :fe_engagements,  :dependent => :destroy
  has_many :fe_interceptors, :dependent => :destroy
  has_many :fe_launchers,    :dependent => :destroy
  has_many :fe_threats,      :dependent => :destroy
  
  validates_associated :fe_areas, :fe_engagements, :fe_interceptors,
                       :fe_launchers, :fe_threats
                       
  named_scope :run, lambda { |*args| { :conditions => {:id => args.first || FeRun.last.id} } }
                       
  ####################
  # Update a run with the latest frame and time
  #   info: {:frame, :id}
  def update_run(info)
    pp info
    
    self.last_frame = info[:frame]
      
    self.save
  end ## def self.update_run(info)
end
