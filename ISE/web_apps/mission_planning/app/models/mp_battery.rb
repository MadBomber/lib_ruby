## The mp_battery_configurations table belongs to this class as a join table.
## It gives access to the mp_launchers table through it.
## The mp_launchers table gives access to mp_interceptors and mp_launcher_doctrines.

class MpBattery < ActiveRecord::Base

  self.establish_connection $MISSION_PLANNING_CONFIG

  before_validation { |r| r.name.downcase! }

  validates_presence_of :name
  
  validates_uniqueness_of :name
  validates_length_of :name, :maximum => DEFAULT_NAME_LENGTH
  validates_format_of :name, :with => DEFAULT_NAME_REGEXP
  
  has_many :mp_battery_configurations, :dependent => :destroy
  has_many :mp_launchers, :through => :mp_battery_configurations
  has_many :mp_interceptors, :through => :mp_launchers
  has_many :mp_launcher_doctrines, :through => :mp_launchers
  
  validates_associated :mp_battery_configurations, :mp_launchers
  
  ## TODO: Having trouble with getting the reject_if to properly work.
  ##       It appears that it rejects no matter what.
  accepts_nested_attributes_for :mp_battery_configurations,
    #:reject_if => lambda { |a| a[:mp_battery_id].blank? or a[:mp_launcher].blank? or a[:mp_launcher_qty].blank? },
    :allow_destroy => true


end
