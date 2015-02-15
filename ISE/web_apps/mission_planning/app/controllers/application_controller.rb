# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  layout "main"
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details
  
=begin  
  ## get root path symbol for class
  def self.class_path_sym
    return class_path_str.to_sym
  end
  
  ## get root path string for class
  def self.class_path_str
    return ('mp_' + root_name.underscore + '_path')
  end
  
  ## get root name from class
  def self.root_name(long_name = nil)
    str = long_name || name # assign name if long_name is nil
    front = 0
    back = str.length
    
    headers = ['Mp']
    footers = ['Controller', 'Helper']
    
    # get new front
    headers.each do |header|
      len = header.length
      
      if str[front..len - 1] == header
        front += len
        break
      end
    end
    
    # get new back
    footers.each do |footer|
      len = footer.length      
      
      if str[(back - len)..back] == footer
        back -= len + 1
        break
      end
    end
    
    return str[front..back]
  end
=end

  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password
end
