# This file is only for example of how it used to be done.
# It should be deleted when Force Effectiveness is finished.







class FeMainController < ApplicationController
  #########
  # GET /
  def index
    
  end ## def index
  
  
  ########
  # GET /run/id
  def show
    get_summary_stats(params[:id])
  end ## def show
  
  
  ##############################################################################
  ##                           Private Class Methods                          ##
  ##############################################################################
  private
  
  
  ###################################
  # Get the summary statistics
  def get_summary_stats(run_id = nil)
    fe_run = FeRun.run(run_id)
    
    if fe_run.nil?
      render :text => "There are no runs in the database!"
    else
      @eng_stats = get_stats(FeEngagement.run(run_id), [:succeeded, :failed, :canceled])
      @thr_stats = get_stats(FeThreat.run(run_id), [:air, :space, :destroyed, :impacted])
      @int_stats = get_stats(FeInterceptor.run(run_id), [:terminated, :hit, :missed])
      
      @run_stats = {
        :id    => fe_run.id,
        :time  => get_run_time(fe_run),
        :score => get_fe_score(@int_stats[:pct_miss], @thr_stats[:pct_impa])   
      }
    
      render :layout => false
    end ## if fe_run.nil?
  end ## def get_summary_stats(run_id = nil)
  
 
  ################################## 
  def get_stats(objects, attributes)
    stats = Hash.new
    
    stats[:num] = objects.count
      
    attributes.each do |attribute|
      stats.merge!(get_attribute(objects, category, attribute))
    end
    
    return stats
  end ## def get_stats(objects, attributes)
  
  
  #####################################
  def get_attribute(objects, attribute)
    attributes = Hash.new
    
    num_str = "num_@{abrev(attribute)}"
    pct_str = "pct_@{abrev(attribute)}"
    
    if objects.count > 0
      attributes[num_str] = objects.method(attribute).call.count
      attributes[pct_str] = stats[num_str].to_f / objects.count.to_f
    else
      attributes[num_str] = 0
      attributes[pct_str] = 0.0
    end
    
    return attributes
  end ## def get_attribute(objects, attribute)
  
  
  #################
  def abrev(symbol)
    return symbol.to_s[0..3].to_sym
  end ## def abrev(symbol)

=begin
  ########################
  def get_run_time(fe_run)
    return fe_run.last_frame - fe_run.first_frame
  end ## def get_run_time(fe_run)
=end

  ####################################
  def get_fe_score(pct_miss, pct_leak)
    return 100 - (pct_miss + pct_leak * 3) / 4
  end ## def get_fe_score(pct_miss, pct_leak)
  
  
  
  
  
  
  
  
  
  ############################################
  ## GET_THREAT_MIX
  ############################################  
  def get_threat_mix
    @ThreatMix = RuntimeThreat.all(
      :group => "threat_type_id", 
      :joins => :threat_type, 
      :select => 'threat_types.name AS name, COUNT(*) AS count',
      :conditions => 'runtime_threats.GUID = "' + get_guid + '"')

    render :layout => false 
  end
  
  ############################################
  ## GET_MULTI_BOX_QUERY_STATS
  ############################################
  def get_multi_box_query_stats
    get_defended_area_stats()
    get_battery_stats()
    render :layout => false
  end

  ############################################
  ## GET_DEFENDED_AREA_STATS
  ############################################  
  def get_defended_area_stats
    #render :text => params.inspect
    
    conditions = "runtime_threat_events.runtime_event_id = 2 AND runtime_threats.GUID = '" + get_guid + "'" 
    conditions = create_condition(
                    conditions, 
                    params[:defended_areas], 
                    '',
                    'runtime_threat_events.runtime_event_id = 2 AND 
                     runtime_threat_events.event_detail = ')
 
    conditions = create_condition(
                    conditions, 
                    params[:threats], 
                    'threat_types.id = ', 
                    'runtime_threats.id = ')

    @DefendedAreaStats = RuntimeThreat.all(
        :select => 'threat_types.name AS threat_type_name, 
                      runtime_threat_events.event_detail AS da_id,
                      COUNT(threat_types.name) AS count',
        :joins => [ :runtime_threat_events,
                    :threat_type],
        :conditions => conditions,
        :group => "da_id, threat_type_name")
        
    
    
    @da_headers = Array.new()
    defended_areas = Array.new()
            
    test = ""    
    for stat in @DefendedAreaStats
      test = test + "<BR>" + stat.threat_type_name
      @da_headers.push(stat.threat_type_name)
      defended_areas.push(stat.da_id)
    end
    #render :text => test
        
    @da_headers.uniq!
    defended_areas.uniq!
    
    @DefendedAreaNames = Array.new()    
    @defended_area_threats_hash = Hash.new()
    for da in defended_areas
      @defended_area_threats_hash[da] = Array.new(@da_headers.size, 0)
      @DefendedAreaNames[da.to_i] = RuntimeDefendedArea.find(da.to_i).name.split("_")[1]
    end
        
    for stat in @DefendedAreaStats
      @defended_area_threats_hash[stat.da_id][@da_headers.index(stat.threat_type_name)] = stat.count
    end
  
  end

  ############################################
  ## GET_DEFENDED_AREAS
  ############################################
  def get_defended_areas
    @da_hash = Hash.new
    
    @DefendedAreas = RuntimeThreatEvent.all(
                        :select => 'DISTINCT(event_detail) AS da_id', 
                        :order => 'da_id ASC', 
                        :joins => :runtime_threat,
                        :conditions => 'runtime_threat_events.runtime_event_id =  2  AND 
                                        runtime_threats.GUID = "' + get_guid + '"')

    for da in @DefendedAreas do
      da_object = RuntimeDefendedArea.find(da.da_id)
      if da_object.nil?
        name = "DA" + da.da_id.to_s
      else
        name = da_object.name.split("_")[1]
      end
      
      @da_hash[name] = da.da_id   
    end
    
    @da_hash["**All DAs"]="ALL"
    @da_hash = @da_hash.sort
  end

  ############################################
  ## GET_BATTERIES
  ############################################  
  def get_batteries
    @bat_hash = Hash.new
    
    @Batteries = RuntimeBattery.all(
                  :select => 'DISTINCT(battery_id) AS bat_id, batteries.name AS bat_name', 
                  :order => 'bat_id ASC', 
                  :joins => :battery,
                  :conditions => 'runtime_batteries.GUID = "' + get_guid() + '"')
 
    for bat in @Batteries do
      ## FIXME: Quick fix to remove the words "THAAD" and "Patriot" from force effectiveness gui
      case bat.bat_name
      when 'THAAD Battery'
        bat_name = 'UT Battery'
      when 'Patriot Battery'
        bat_name = 'LT Battery'
      else
        bat_name = bat.bat_name
      end
      @bat_hash["*All " + bat_name + "(s)"] = "DISTINCT_" + bat.bat_id   
    end
    
    @Batteries = RuntimeBattery.all(:select => 'name, id', :conditions => 'runtime_batteries.GUID = "' + get_guid() + '"')
    
    for bat in @Batteries do
      @bat_hash[bat.name] = bat.id   
    end
    
    @bat_hash["**All Batteries"]="ALL"
    @bat_hash = @bat_hash.sort 
  end

  ############################################
  ## GET_THREATS
  ############################################  
  def get_threats
    @threat_hash = Hash.new
    
    @Threats = RuntimeThreat.all(
                  :select => 'DISTINCT(threat_type_id) AS threat_id, threat_types.name AS threat_name', 
                  :order => 'threat_id ASC', 
                  :joins => :threat_type,
                  :conditions => 'runtime_threats.GUID = "' + get_guid + '"')
    
    for threat in @Threats do
      @threat_hash["*All " + threat.threat_name + "(s)"] = "DISTINCT_" + threat.threat_id
    end
    
    @threat_hash["**All Threats"]="ALL"
    @threat_hash = @threat_hash.sort  
 
  end

  ############################################
  ## GET_INTERCEPT_EVENTS
  ############################################  
  def get_intercept_events
    
    @inter_hash = Hash.new
    
    @InterceptEvents = RuntimeInterceptorEvent.all(
                        :select => 'DISTINCT(runtime_event_id) AS intercept_id, runtime_events.name AS intercept_name', 
                        :order => 'intercept_id ASC', 
                        :joins => [:runtime_event, :runtime_interceptor],
                        :conditions => 'runtime_interceptors.GUID = "' + get_guid() + '"')
    
    for inter in @InterceptEvents do
      @inter_hash[inter.intercept_name] = inter.intercept_id
    end
    
    @inter_hash["**All Engagements"] = "ALL"
    @inter_hash = @inter_hash.sort
    
  end

  ############################################
  ## GET_MULTI_BOX_QUERY
  ############################################
  def get_multi_box_query
    get_defended_areas()
    get_batteries()
    get_threats()
    get_intercept_events()
    render :layout=> false
  end

  ############################################
  ## CREATE_CONDITION
  ############################################  
  def create_condition(conditions, parameter, condition_if_distinct, condition_if_id)
    all_keyword = "ALL"
    distinct_keyword = "DISTINCT_"
    
    if !parameter.nil?
        parameter_string = parameter.to_s
    
        if parameter_string != all_keyword
          
          if !conditions.empty?
            conditions = conditions + " AND "
          end
          
          if parameter_string.include? distinct_keyword
            conditions = conditions + condition_if_distinct + parameter_string[distinct_keyword.length..parameter_string.length]
          else
            conditions = conditions + condition_if_id + parameter_string
          end
        
        end
         
    end
    
    return conditions
  end
  
  ############################################
  ## GET_BATTERY_STATS
  ############################################ 
  def get_battery_stats
  
    conditions = "runtime_interceptors.GUID = '" + get_guid + "'"
 
    if params[:threats]
      conditions = create_condition(
                      conditions, 
                      params[:threats], 
                      'threat_types.id = ', 
                      'runtime_threats.id = ')
    end
                    
    if params[:batteries]
      conditions = create_condition(
                          conditions, 
                          params[:batteries], 
                          'runtime_batteries.battery_id = ', 
                          'runtime_batteries.id = ')
    end
    
    if params[:intercept_events]                    
      conditions = create_condition(
                          conditions, 
                          params[:intercept_events], 
                          '', 
                          'runtime_interceptor_events.runtime_event_id = ')
    end
    
    #render :text => params.inspect
    #render :text => conditions
    @condition_string = conditions
 
    @BatteryStats = RuntimeInterceptor.all(
      :select => 'runtime_batteries.name AS battery_name, 
                  runtime_events.name AS event_name,
                  COUNT(runtime_interceptor_events.id) AS event_count',
      :joins => [ :runtime_launcher => :runtime_battery,
                  :runtime_interceptor_events => 
                      [:runtime_event,
                        {:runtime_threat => :threat_type}]
                ],
      :conditions => conditions,
      :group => 'battery_name, runtime_interceptor_events.runtime_event_id'
      )
    
    @TRY_ME = conditions
    
    @bat_headers = Array.new()
    batteries = Array.new()

    for battery in @BatteryStats
      @bat_headers.push(battery.event_name)
      batteries.push(battery.battery_name)
    end
    
    @bat_headers.uniq!
    batteries.uniq!
    batteries = batteries.sort
    
    @battery_event_hash = Hash.new()
    for battery in batteries
      @battery_event_hash[battery] = Array.new(@bat_headers.size, 0)
    end
    
    for battery in @BatteryStats
      @battery_event_hash[battery.battery_name][@bat_headers.index(battery.event_name)] = battery.event_count
    end

  end

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
  end

  ############################################
  ## GET_COST_OF_ROUNDS_EXPENDED
  ############################################
  def get_cost_of_rounds
    @Rounds = RuntimeInterceptor.all(
     :select => 'runtime_batteries.name AS battery_name, track_categories.name AS track_type, SUM(interceptors.cost) AS cost',
      :joins => [ {:runtime_launcher => :runtime_battery}, 
                  {:runtime_interceptor_events => 
                        {:runtime_threat => 
                              {:threat_type => :track_category}}},
                   :interceptor],
      :conditions => 'runtime_interceptors.GUID = "' + get_guid + '" AND 
                      runtime_interceptor_events.runtime_event_id = 8',
      :group => 'battery_name, track_type'
    )
    
    track_types = Array.new()
    batteries = Array.new()
    
    for round in @Rounds
      track_types.push(round.track_type)
      batteries.push(round.battery_name)
    end
    
    track_types.uniq!
    batteries.uniq!
        
    track_type_battery_hash = Hash.new()
    
    for track_type in track_types
      track_type_battery_hash[track_type] = Array.new(batteries.size, 0)
    end
    
    for round in @Rounds
      track_type_battery_hash[round.track_type][batteries.index(round.battery_name)] = round.cost
    end
    
    text = ""
    for round in @Rounds
      text = text + round.battery_name + ": " + round.track_type + "($" + round.cost + ") <br/>"
    end
    
    #inputs
    series_hash = track_type_battery_hash
    x_axis_labels = batteries
    x_axis_index_multiplier = 5
    flotr_chart_title = "Cumulative Cost of Rounds Expended"
    
    #Initialize Values
    x_axis_max = 0
    y_axis_max = 0

    flotr_hash = Hash.new()
    flotr_series_array = Array.new();
    
    first_series = true
    x_axis_ticks = Array.new();
    
    series_hash.each_pair do |series_name, x_axis_data_array|
           
      flotr_series_hash = Hash.new()
      
      flotr_series_hash['label'] = series_name
      flotr_series_hash['xaxis'] = 1
      flotr_series_hash['data'] = Array.new()
      
      i = 0
      x_axis_data_array.each do |value|
        flotr_series_hash['data'][i] = Array.new(2)
        flotr_series_hash['data'][i][0] = i * x_axis_index_multiplier
        flotr_series_hash['data'][i][1] = value

        if first_series
          x_axis_ticks[i] = Array.new()
          x_axis_ticks[i][0] = i * x_axis_index_multiplier
          
          tick_name = ""
          tick_name_parts = batteries[i].split("_") 
          for part in tick_name_parts
            tick_name += part[0..0]
          end
          
          x_axis_ticks[i][1] = tick_name
        end
        
        i = i + 1
        if i > x_axis_max  
          x_axis_max = i 
        end
        
        if value.to_i > y_axis_max
          y_axis_max = value.to_i
        end
        
      end
      
      flotr_series_array.push(flotr_series_hash)
       
    end

    flotr_options_hash = Hash.new()
    flotr_options_hash['title'] = flotr_chart_title
    
    flotr_options_hash['bars'] = Hash.new()
    flotr_options_hash['bars']['show'] = true
    flotr_options_hash['bars']['barWidth'] = 1
    flotr_options_hash['bars']['centered'] = true
    flotr_options_hash['bars']['stacked'] = true   
        
    flotr_options_hash['yaxis'] = Hash.new()
    flotr_options_hash['yaxis']['noTicks'] = 5
    flotr_options_hash['yaxis']['showLabels'] = true
    flotr_options_hash['yaxis']['autoScaleMargin'] = 0
    flotr_options_hash['yaxis']['min'] = 0
    flotr_options_hash['yaxis']['max'] = y_axis_max + 100
        
    flotr_options_hash['xaxis'] = Hash.new()
    flotr_options_hash['xaxis']['noTicks'] = 5
    flotr_options_hash['xaxis']['showLabels'] = true
    flotr_options_hash['xaxis']['autoScaleMargin'] = 0
    flotr_options_hash['xaxis']['min'] = 0
    flotr_options_hash['xaxis']['max'] = x_axis_max * x_axis_index_multiplier
    flotr_options_hash['xaxis']['ticks'] = x_axis_ticks

    flotr_hash['options'] = flotr_options_hash
    flotr_hash['series'] = flotr_series_array
        
    render :text => flotr_hash.to_json
    
  end
  
  
  
end ## class FeMainController < ApplicationController
