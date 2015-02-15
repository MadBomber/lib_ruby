module EmThreatsHelper
  
  ####################
  def get_interceptors
    return nil unless (threat = EmThreatsController.get_current_threat)
    
  	interceptors = Array.new
  	
  	## Get all interceptors against this threat from all launchers
  	threat.launchers.each_value do |launcher|
  	  interceptors += launcher.interceptors.values
  	end
  	
  	interceptors.sort! { | a, b | a.intercept_time <=> b.intercept_time }
  	
  	return interceptors
  end ## def get_interceptors
  
end ## module EmThreatsHelper
