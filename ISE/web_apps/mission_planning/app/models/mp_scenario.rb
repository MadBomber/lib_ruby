require 'debug_me'

class MpScenario < ActiveRecord::Base
 
  self.establish_connection $MISSION_PLANNING_CONFIG


  validates_presence_of     :name, :idp_name, :sg_name, :random_threat_count

  validates_numericality_of :random_threat_count, :greater_than_or_equal_to => 0,  :message => "Must be numberic greater than or equal to zero."
    
  validates_uniqueness_of   :name, :message => "Can not be the same as an existing scenario name."
  validates_length_of       :name, :maximum => DEFAULT_NAME_LENGTH, :message => "Length can not exceed #{DEFAULT_NAME_LENGTH} characters."
#  validates_format_of       :name, :with => DEFAULT_NAME_REGEXP, :message => "Can not have upper case letters, spaces or special characters."
  
  named_scope :selected, :conditions => ['selected = ?', true]



  # FIXME: The need for this method may go away with Rails/ActiveRecord version 3+
  def has_errors?    
    return !@errors.empty?
  end


end
