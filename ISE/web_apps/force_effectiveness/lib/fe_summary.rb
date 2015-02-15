module FeSummary
  ##############################################################################
  ##                              Private Methods                             ##
  ##############################################################################
  private
  
  ###################################
  # Get the summary statistics
  #   run_id: The run to get stats for
  def get_summary_stats
    unless @fe_run.nil?
      @eng_stats = get_stats(FeEngagement.run(@run_id), [:canceled, :engaging, :failed, :pending, :succeeded])
      @thr_stats = get_stats(FeThreat.run(@run_id), [:air, :space, :destroyed, :flying, :impacted])
      @int_stats = get_stats(FeInterceptor.run(@run_id), [:engaging, :hit, :missed, :terminated])
      
      @fe_score = get_fe_score(@int_stats[:pct_miss], @thr_stats[:pct_impa])
    end ## if fe_run.nil?
  end ## def get_summary_stats
  
 
  ##################################
  # Get stats hash for objects with the listed attributes
  #   objects: objects to get stats on
  #   attributes: attributes to analyize objects
  def get_stats(objects, attributes)
    stats = Hash.new
    
    stats[:num] = objects.count
      
    attributes.each do |attribute|
      stats.merge!(get_attribute(objects, attribute))
    end
    
    return stats
  end ## def get_stats(objects, attributes)
  
  
  #####################################
  # Get attributes hash for objects with the listed attribute
  #   objects: objects to get stats on
  #   attribute: attribute to analyize objects
  def get_attribute(objects, attribute)
    attributes = Hash.new
    
    num_str = "num_#{abrev(attribute)}".to_sym
    pct_str = "pct_#{abrev(attribute)}".to_sym
    
    if objects.count > 0
      attributes[num_str] = objects.method_missing(attribute).count
      attributes[pct_str] = 100.0 * attributes[num_str].to_f / objects.count.to_f
    else
      attributes[num_str] = 0
      attributes[pct_str] = 0.0
    end
    
    return attributes
  end ## def get_attribute(objects, attribute)
  
  
  #################
  # Abreviate a attribute to four letters
  #   attribute: attribute symbol to be abreviated
  def abrev(attribute)
    return attribute.to_s[0..3].to_sym
  end ## def abrev(attribute)


  


  ####################################
  # Get the force effectiveness score.
  # Leaks are weighted three times higher.
  #   pct_miss: The percentage of interceptors which missed.
  #   pct_leak: The percentage of threats which leaked.
  def get_fe_score(pct_miss, pct_leak)
    return 100 - (pct_miss + pct_leak * 3) / 4
  end ## def get_fe_score(pct_miss, pct_leak)  
end
