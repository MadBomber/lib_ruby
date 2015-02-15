## The join table for mp_tewa_factors and mp_tewa_configurations.
## Because of this, it belongs to both tables.
class MpTewaValue < ActiveRecord::Base
  self.establish_connection $MISSION_PLANNING_CONFIG

  validates_presence_of :value
  validates_numericality_of :value, :only_integer => true,
    :message => 'must be an integer.'
  validates_inclusion_of :value, :in => 0..100,
    :message => "can not be less than zero or greater than 100."
  
  belongs_to :mp_tewa_configuration
  belongs_to :mp_tewa_factor
end
