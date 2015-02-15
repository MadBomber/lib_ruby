#############################
# returns category from fe object label
# params: label = &&CATEGORY_###
# example: BMPAC3_001 => pac3
def fe_object_category(label)
  return label.split('_')[0][2, label.length - 1].downcase
end ## def fe_object_category(label)


###########################################
# returns the label of a particular object type from a info hash
# params:
#   object_category: type of object (ex: launcher, interceptor, etc.)
#   info: {:&&&&&_label or :label, ...}
def get_object_label(object_category, info)
  cat_label = "#{object_category}_label".to_sym
  
  return info.include?(cat_label) ? info[cat_label] : info[:label]
end ## def get_object_label(object_category, info)
  

module FeErrorMethods 
  ##############################################################################
  ##                           Error Output Methods                           ##
  ##############################################################################
  
  def simple_error error_msg
    $stderr.puts
    $stderr.puts "\t#{error_msg}"
    $stderr.puts
  end
  
  #########################
  def trace_error error_msg
    $stderr.puts trace_error_str(error_msg)
  end
  
  
  #############################
  def trace_error_str error_msg
    return "\n\t#{error_msg}\n#{get_trace}\n"
  end
  
  
  #############
  def get_trace
    c = caller
  
    # remove error helpers
    c.delete_at 0 while c[0][/get_trace|trace_error|trace_warning|internal_error|fatal_error|die/]
    
    return "\tSTACK TRACE:\n\t\tfrom #{c.join("\n\t\tfrom ")}\n" 
  end
  
  ##############################
  def simple_warning warning_msg
    simple_error "WARNING: #{warning_msg}"
  end
  
  #############################
  def trace_warning warning_msg
    trace_error "WARNING: #{warning_msg}"
  end
  
  ############################
  def internal_error error_msg
    trace_error "INTERNAL SYSTEM ERROR: #{error_msg}"
  end
  
  
  ###################################
  def fatal_error error_msg
    trace_error "FATAL ERROR: #{error_msg}"
    exit(-1)
  end
  
  alias :die :fatal_error
  
end ## module FeErrorMethods
