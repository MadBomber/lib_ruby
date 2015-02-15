## The mp_tewa_value table belongs to this class as a join table.
## It gives access to the mp_tewa_configurations table through it.
class MpTewaFactor < ActiveRecord::Base
  self.establish_connection $MISSION_PLANNING_CONFIG


  validates_presence_of :name, :category
  
  validates_uniqueness_of :name
  validates_length_of :name, :maximum => TEWA_NAME_LENGTH
  validates_format_of :name, :with => TEWA_NAME_REGEXP
  
  validates_length_of :category, :maximum => TEWA_NAME_LENGTH
  validates_format_of :category, :with => TEWA_NAME_REGEXP
  validates_inclusion_of :category,
    :in => %w( threat_evaluation threat_type weapon_assignment ),
    :message => 'must be threat_evaluation, threat_type, or weapon_assignment.'
  
  has_many :mp_tewa_values, :dependent => :destroy
  has_many :mp_tewa_configurations, :through => :mp_tewa_values
  
  named_scope :threat_types, :conditions => [ 'category = ?', 'threat_type' ]
  named_scope :threat_evaluations, :conditions => [ 'category = ?', 'threat_evaluation' ]
  named_scope :weapon_assignments, :conditions => [ 'category = ?', 'weapon_assignment' ]
    
  def self.categories
    return [:threat_type, :threat_evaluation, :weapon_assignment]
  end
end
