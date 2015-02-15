class MpThreat < ActiveRecord::Base
  self.establish_connection $MISSION_PLANNING_CONFIG
  
  validates_presence_of :name, :track_category, :effects_radius
  
  validates_uniqueness_of :name
  validates_length_of :name, :maximum => DEFAULT_NAME_LENGTH
  validates_format_of :name, :with => DEFAULT_NAME_REGEXP
  
  validates_length_of :track_category, :maximum => TEWA_NAME_LENGTH
  validates_format_of :track_category, :with => TEWA_NAME_REGEXP
  validates_inclusion_of :track_category, :in => %w( air space ),
    :message => 'must be air or space.'
  
  validates_numericality_of :effects_radius, :greater_than_or_equal_to => 0
end
