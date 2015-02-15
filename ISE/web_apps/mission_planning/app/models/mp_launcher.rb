## The mp_battery_configurations table belongs to this class as a join table.
## It gives access to the mp_batteries table through it.
## This class also belongs to mp_interceptors and mp_launcher_doctrines
## It 'belongs' because that allows access to interceptors and launch areas from
## other tables.
##
## TODO: the name attribute is really a launcher type
##
class MpLauncher < ActiveRecord::Base
  self.establish_connection $MISSION_PLANNING_CONFIG

  validates_presence_of :name, :mp_interceptor, :mp_interceptor_qty, :abt_doctrine, :tbm_doctrine
  
  validates_uniqueness_of :name
  validates_length_of :name, :maximum => DEFAULT_NAME_LENGTH
  validates_format_of :name, :with => DEFAULT_NAME_REGEXP

  validates_numericality_of :mp_interceptor_qty, :only_integer => true,
    :message => 'must be an integer.'
  validates_numericality_of :mp_interceptor_qty, :greater_than_or_equal_to => 0

  has_many :mp_battery_configurations 
  has_many :mp_batteries, :through => :mp_battery_configurations
  belongs_to :mp_interceptor
  
  belongs_to :abt_doctrine, :class_name => "MpLauncherDoctrine",  :foreign_key => "abt_doctrine_id" 
  belongs_to :tbm_doctrine, :class_name => "MpLauncherDoctrine",  :foreign_key => "tbm_doctrine_id" 

  
  validates_associated :mp_interceptor, :abt_doctrine, :tbm_doctrine
  
  
  
  validate :launcher_name_equals_interceptor_name

  def launcher_name_equals_interceptor_name
    unless self.name == @mp_interceptor.name
      errors.add_to_base "Launcher Type MUST BE the same as Interceptor Type [#{self.name} is not the same as #{@mp_interceptor.name}]"
    end
  end

  
  
  
end
