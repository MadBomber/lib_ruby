class MpLauncherDoctrine < ActiveRecord::Base
  self.establish_connection $MISSION_PLANNING_CONFIG
    
  validates_uniqueness_of :name
  validates_length_of :name, :maximum => DEFAULT_NAME_LENGTH
  validates_format_of :name, :with => DEFAULT_NAME_REGEXP
  
  # has_many :mp_launcher
  
  has_many :abt_launcher,  :class_name => "MpLauncher",  :foreign_key => "abt_doctrine_id"   
  has_many :tbm_launcher,  :class_name => "MpLauncher",  :foreign_key => "tbm_doctrine_id"   
      
end
