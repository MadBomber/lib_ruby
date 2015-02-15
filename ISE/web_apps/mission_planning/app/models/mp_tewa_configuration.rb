## The mp_tewa_value table belongs to this class as a join table.
## It gives access to the mp_tewa_factors table through it.
class MpTewaConfiguration < ActiveRecord::Base
  self.establish_connection $MISSION_PLANNING_CONFIG
    
  
  validates_presence_of :name           # SMELL:, :doctrine
  
  validates_uniqueness_of :name, :message => "can not be a duplicate of an existing TEWA scenario name."
  validates_length_of :name, :maximum => TEWA_NAME_LENGTH, :message => "can not be longer than #{TEWA_NAME_LENGTH} characters."
  validates_format_of :name, :with => TEWA_NAME_REGEXP, :message => "can not have uppercase letters, spaces or special characters."
  
  has_many :mp_tewa_values, :dependent => :destroy
  has_many :mp_tewa_factors, :through => :mp_tewa_values
  
  named_scope :doctrine, :conditions => ['doctrine = ?', true]
  named_scope :selected, :conditions => ['selected = ?', true]
  
  
  ## TODO: Having trouble with getting the reject_if to properly work.
  ##       It appears that it rejects no matter what.
  accepts_nested_attributes_for :mp_tewa_values,
    #:reject_if => lambda { |a| a[:mp_tewa_configuration_id].blank? or a[:mp_tewa_factor_id].blank? or a[:value].blank? },
    :allow_destroy => true
end
