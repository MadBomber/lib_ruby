module FeQuery
  def _query_stats
    unless params['launchers'].nil? or params['interceptors'].nil?
      @laun_int_events  = get_laun_int_events(params['launchers'], params['interceptors'])
    end
    
    relabel_events(@laun_int_events, @laun_int_event_cats, :destroyed, :terminated)
    
    unless params['defended_areas'].nil? or params['threats'].nil?
      @da_threat_events = get_da_threat_events(params['defended_areas'], params['threats'])
    end
    
    relabel_events(@da_threat_events, @da_threat_event_cats, :destroyed, :killed)
  end
  
  
  def relabel_events(events_hash, event_header, old_label, new_label)
    events_hash.each_pair do |launcher_label, event_cats|
      event_cats.each_pair do |event_label, event_num|
        if event_label == old_label
          events_hash[launcher_label][new_label] = event_num
          events_hash[launcher_label].delete(old_label)
        end
      end
    end
    
    event_header.delete(old_label)
    event_header << new_label
  end
  
  
  def get_laun_int_events(launcher_ids, interceptor_ids)
    
    launcher_ids = format_ids(launcher_ids)
    interceptor_ids = format_ids(interceptor_ids)
    
    selected_launchers    = get_objects_by_id(:launcher, launcher_ids)
    
    @laun_int_event_cats = [
      :engaging,
      :hit,
      :missed,
      :canceled,
      :destroyed
    ]
    
    event_cats = get_event_cats(@laun_int_event_cats)
    
    events = Hash.new
    
    selected_launchers.each do |launcher|
      events[get_object_str(launcher)] = event_cats.dup
      
      events[get_object_str(launcher)].each_pair do |event_label, event_num|
        interceptors = launcher.fe_interceptors.method_missing(event_label)
        
        interceptors.each do |interceptor|
          events[get_object_str(launcher)][interceptor.status.to_sym] += 1 if interceptor_ids.include?(interceptor.id)
        end
      end
    end
    
    return events
  end
  
  
  
  def get_da_threat_events(da_ids, threat_ids)
    da_ids     = format_ids(da_ids)
    threat_ids = format_ids(threat_ids)
    
    
    selected_threats = get_objects_by_id(:threat, threat_ids)
    selected_areas   = get_objects_by_id(:area, da_ids, :targets)
    
    @da_threat_event_cats = [
      :flying,
      :destroyed,
      :impacted
    ]
    
    event_cats = get_event_cats(@da_threat_event_cats)
    
    events = Hash.new
    
    selected_areas.each do |area|
      events[get_object_str(area)] = event_cats.dup
    end
    
    selected_threats.each do |threat|
      if da_ids.include?(threat.target_area_id)
        events[get_object_str(threat.target_area)][threat.status.to_sym] += 1
      end
    end
    
    return events
  end
  
  def get_event_cats(event_list)
    event_cats = Hash.new
    
    event_list.each do |event|
      event_cats[event] = 0
    end
    
    return event_cats
  end
  
  def get_objects_by_id(object_type, selected_ids, *args)
    obj_mdl = object_model(object_type)
    
    objs = Array.new
    
    unless selected_ids.nil?
      selected_ids.each do |selected_id|
        objs << obj_mdl.find(selected_id)
      end
    else
      objs = get_all_run_objects(object_type, *args)
    end
    
    return objs
  end
  
  ###########################################
  # Get all objects in a run modified by by optional named_scopes
  #   object_type: the symbol representing the object type
  #   *args: The named scopes to use on the object model
  def get_all_run_objects(object_type, *args)
    objs = object_model(object_type).run(@run_id)
    
    args.each do |arg|
      objs = objs.method_missing(arg)
    end
    
    return objs
  end ## def get_all_run_objects(object_type, *args)
    
  def get_query_arrays
    @das          = get_query_array(:area, :targets)
    @interceptors = get_query_array(:interceptor)
    @launchers    = get_query_array(:launcher)
    @threats      = get_query_array(:threat)
    
    @queries = [
      ['launchers',      @launchers],
      ['interceptors',   @interceptors],
      ['defended_areas', @das],
      ['threats',        @threats]
    ]
  end
  
  def get_query_array(object_type, *args)
    objs = get_all_run_objects(object_type, *args)
    
    object_hash = Hash.new
    
    objs.each do |obj|
      object_hash[get_object_str(obj)] = obj.id
    end
    
    object_array = [['ALL',object_hash.values.sort.join(',')]] + object_hash.to_a.sort
    
    return object_array
  end
  
  def get_object_str(object)
    if object.class == FeArea
      return object.label.titleize
    else
      return object.label[2..(object.label.length - 1)].humanize.upcase
    end
  end
  
  def object_model(object_type)
    return eval("Fe#{object_type.to_s.capitalize}")
  end 
  
  def format_ids(ids)
    if ids.size == 1 and ids[0].include?(',')
      ids = ids[0].split(',')
    end
    
    ids.each_index do |index|
      ids[index] = ids[index].to_i
    end
    
    return ids
  end
  
end