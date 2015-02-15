## The mp_launchers table belongs to this class.
## It gives access to the mp_batteries table through it.
class MpInterceptor < ActiveRecord::Base
  self.establish_connection $MISSION_PLANNING_CONFIG

  validates_presence_of :name , :pk_air, :pk_space, :velocity, :cost,
    :eng_zone_scale_air, :eng_zone_scale_space, :max_range_meters
  
  validates_uniqueness_of :name
  validates_length_of :name, :maximum => DEFAULT_NAME_LENGTH
  validates_format_of :name, :with => DEFAULT_NAME_REGEXP

  validates_numericality_of :pk_air, :pk_space, :cost, :velocity,
    :eng_zone_scale_air, :eng_zone_scale_space, :only_integer => true,
    :message => 'must be an integer.'
  validates_inclusion_of :pk_air, :pk_space, :cost, :in => 0..100,
    :message => 'must be between 0 and 100.'
  validates_numericality_of :velocity, :eng_zone_scale_air,
    :eng_zone_scale_space, :greater_than_or_equal_to => 0
       
  has_many :mp_launchers, :dependent => :destroy
  has_many :mp_batteries, :through => :mp_launchers
end
