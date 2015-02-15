module FeChart
  @@x_axis_index_mult = 5
  
  ############################################
  ## GET_ENGAGEMENT_RESULTS
  ############################################
  def get_eng_results
  
    @EngResults = RuntimeBatteryEvent.all(
        :select => 'runtime_threat_events.event_detail AS da_id,
                      track_categories.name AS track_type,
                      runtime_events.name AS result, 
                      COUNT(runtime_events.name) AS event_count',
        :conditions => 'runtime_threats.GUID = "' + get_guid() + '" AND 
                        runtime_threat_events.runtime_event_id = 2 AND 
                        runtime_battery_events.runtime_event_id not in (10,12,13)',
        :joins => [:runtime_event, {:runtime_threat => [:runtime_threat_events, {:threat_type => :track_category}]}], 
        :group => 'da_id, track_type, result') 
    
    @da_ids = Array.new()
    results = Array.new()
    @track_types = Array.new()
    
    
  
    
    for result in @EngResults
      @da_ids.push(result.da_id)
      results.push(result.result)
      @track_types.push(result.track_type)
    end
    
    @da_ids.uniq!
    results.uniq!
    @track_types.uniq!
    
    @DefendedAreaNames = Array.new()  
    for da_id in @da_ids
       @DefendedAreaNames[da_id.to_i] = RuntimeDefendedArea.find(da_id.to_i).name.split("_")[1] 
    end
    
    @result_da_category_hash = Hash.new()
    
      
    for result in results
      @result_da_category_hash[result] = Hash.new()
      
      for da_id in @da_ids
        @result_da_category_hash[result][da_id] = Array.new(@track_types.size, 0)
      end
      
    end
  
    for result in @EngResults
      @result_da_category_hash[result.result][result.da_id][@track_types.index(result.track_type)] = result.event_count
    end
  
    render :layout => false
  end ## def get_eng_results
  
  ############################################
  ## GET_COST_OF_ROUNDS_EXPENDED
  ############################################
  def get_cost_of_interceptors
    cost_hash = get_cost_per_threat_category_and_launcher
    
    #inputs
    series_hash = cost_hash
    title = "Cost of Interceptors"
    
    #Initialize Values
    x_max = 0
    y_max = 0
  
    flotr_hash = Hash.new()
    flotr_series_array = Array.new();
    ticks = Array.new();
    
    # Each threat type with it's associated batteries... each battery has a cost of rounds fired
    series_hash.each_pair do |series_name, x_axis_data_array|
           
      flotr_series_hash = Hash.new()
      
      flotr_series_hash['label'] = series_name
      flotr_series_hash['xaxis'] = 1
      flotr_series_hash['data'] = Array.new()
      
      i = 0
      
      
      
      ticks[i] = get_ticks(launchers)
      
      
      launchers.each_pair do |launcher_label, interceptor_cost|
        
      end
      
      
      
      # so, ticks are an array of [tick_loc, tick_str] pairs
      
      
      # it looks like the x index is supposed to be 5 times bigger than the regular index into arrays
      
      # each battery for a given threat type has a cost 'value'
      x_axis_data_array.each do |value|
        flotr_series_hash['data'][i] = Array.new(2)
        flotr_series_hash['data'][i][0] = i * @@x_axis_index_mult # i think this is to separate things??
        flotr_series_hash['data'][i][1] = value
  
        
        ticks[i] = Array.new()
        ticks[i][0] = i * @@x_axis_index_mult
        
        
        # Getting the first letter of each part of the battery names?
        # so just abreviating
        tick_name = ""
        tick_name_parts = batteries[i].split("_") 
        for part in tick_name_parts
          tick_name += part[0..0]
        end
        
        ticks[i][1] = tick_name
        
        
        i = i + 1
        if i > x_max  
          x_max = i 
        end
        
        if value.to_i > y_max
          y_max = value.to_i
        end
        
      end ## x_axis_data_array.each do |value|
      
      flotr_series_array.push(flotr_series_hash)
       
    end
  
    flotr_hash['options'] = get_flotr_options(title, x_max, y_max, ticks)
    flotr_hash['series'] = flotr_series_array
    
        
    render :text => flotr_hash.to_json
    
  end ## def get_cost_of_interceptors
  
  
  #############################################
  def get_cost_per_threat_category_and_launcher
    threat_categories = get_threat_categories
    
    threat_categories.each_pair do |threat_category, launchers|
      
      launchers = Hash.new
      threats = FeThreat.find_by_category(threat_category)
      
      threats.fe_launchers.each do |launcher|
        launcher.interceptors.each do |interceptor|
          # get cost... it's not recorded at all in FE DB
          cost = 0
        end
        
        launchers[launcher.label] = cost
      end ## threats.fe_launchers.each do |launcher|
    end ## threat_categories.each_pair do |threat_category, launchers|
  end ## def get_cost_per_threat_category_and_launcher
  
  
  #########################
  def get_empty_threat_categories_hash
    cats = Hash.new
    
    FeThreat.run(@fe_run).each do |threat|
      cats[threat.category] = nil unless cats.include?(threat.category)
    end 
    
    return cats
  end ## def get_empty_threat_categories_hash
  
  
  def get_ticks(launchers)
    index = 0
    
    ticks = Array.new
    
    launchers.each_key do |label|
      ticks << [ticks.size * @@x_axis_index_mult, abreviate_launcher(label)]
    end
    
    return ticks
  end
  
  def abreviate_launcher(label)
    return "L#{}"
  end
  
  
  ############################################
  def get_flotr_options(title, x_max, y_max, x_ticks)
    flotr_options = Hash.new()
    
    flotr_options['title'] = title
    flotr_options['bars'] = get_flotr_bars
    flotr_options['xaxis'] = get_x_axis(x_max * @@x_axis_index_mult, x_ticks)
    flotr_options['yaxis'] = get_y_axis(y_max + 100)
      
    return flotr_options
  end ## def get_flotr_options(x_max, y_max, x_ticks)
  
  
  ##################
  def get_flotr_bars
    bars = Hash.new
    
    bars['show']     = true
    bars['barWidth'] = 1
    bars['centered'] = true
    bars['stacked']  = true
      
    return bars   
  end ## def get_flotr_bars
  
  
  #######################
  def get_basic_axis(max)
    base = Hash.new
    
    base['noTicks'] = 5
    base['showLabels'] = true
    base['autoScaleMargin'] = 0
    base['min'] = 0
    base['max'] = max
      
    return base
  end ## def get_basic_axis(max)
  
  alias :get_basic_axis :get_y_axis
  
  
  ##########################
  def get_x_axis(max, ticks)
    x_axis = get_basic_axis(max)
    
    x_axis['ticks'] = ticks
      
    return x_axis
  end ## def get_x_axis(max, ticks)
  
end ## module FeChart