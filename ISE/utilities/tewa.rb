#####################################################
###
##  File:  tewa.rb
##  Desc:  Threat Evaluation and Weapon Assignment
##         Gets the tewa-oriented data from the AADSE database
#

require 'aadse_utilities'
require 'aadse_database'

require 'rubygems'
require 'pp'

module Tewa
    
  # Get the selected scenario from the database
  s = MpTewaConfiguration.selected[0]
  
  throw :NoTewaConfigurationSelected if s.nil?
  
  RECORD = s    # keep the database record as a module constant
  
  config = Hash.new

  tewa_values = s.mp_tewa_values

  tewa_values.each do |tv|

    mtf = tv.mp_tewa_factor
    
    tewa_type                   = mtf.category
    config[tewa_type]           = Hash.new unless config.include?(tewa_type)
    config[tewa_type][mtf.name] = tv.value.to_f
  end
  
  required_categories = %w( weapon_assignment threat_evaluation threat_type defended_area launch_area )
  
  required_categories.each do |rc|
    unless config.include?(rc)
      debug_me("ERROR: Missing Category #{rc}") {:config}
      config[rc] = Hash.new
    end
  end

  ###############################################################################
  ## Required items for threat_evaluation
  
  required_items = %w(  threat_type defended_area launch_area time_until_impact )
  
  required_items.each do |ri|
    unless config['threat_evaluation'].include?(ri)
      debug_me("ERROR: Missing Item #{ri}") {"config['threat_evaluation']"}
      config['threat_evaluation'][ri] = 1.0      
    end
  end

  ###############################################################################
  ## Required items for weapon_assignment
  
  required_items = %w( interceptor_pk time_until_ftl rounds_available interceptor_cost )
  
  required_items.each do |ri|
    unless config['weapon_assignment'].include?(ri)
      debug_me("ERROR: Missing Item #{ri}") {"config['weapon_assignment']"}
      config['weapon_assignment'][ri] = 1.0      
    end
  end

  
  CONFIG = config
    
end ## end of module Tewa
