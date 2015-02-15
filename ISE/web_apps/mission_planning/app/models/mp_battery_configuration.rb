## The join table for mp_batteries and mp_launchers.
## Because of this, it belongs to both tables.
class MpBatteryConfiguration < ActiveRecord::Base
  self.establish_connection $MISSION_PLANNING_CONFIG
    
  #validates_presence_of :mp_launcher_qty
  #validates_numericality_of :mp_launcher_qty, :only_interger => true,
  #  :message => 'must be an integer.'
  #validates_numericality_of :mp_launcher_qty, :greater_than_or_equal_to => 0
    
  belongs_to :mp_battery
  belongs_to :mp_launcher
end
