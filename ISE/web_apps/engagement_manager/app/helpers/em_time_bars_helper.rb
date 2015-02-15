module EmTimeBarsHelper
  
  #################################################
  def get_label_for_highest_launcher_bid(launchers)
    label = nil
    high_bid = 0
    
    launchers.each_value do |launcher|
      if launcher.bid > high_bid
        label = launcher.label
        high_bid = launcher.bid
      end
    end
    
    return label
  end
  
  ################################
  def get_time_bar_style(launcher)
    return "launcher_#{ launcher.status }"
  end ## def get_time_bar_style(launcher)
  
  
  ###################
  def get_cell_labels
    cell_labels = [
      'pre_engageable',
      #'earliest_flight',
      'engageable',
      #'latest_flight',
      'unengageable',
      'impacted'
    ]
    
    return cell_labels
  end ## def get_cell_labels
  
  
  ####################
  def get_border_times(launcher)
    em_threat = EmThreatsController.get_current_threat
    current_duration = EmTimeBarsController.get_current_duration
    
    border_times = [
      launcher.first_launch_time,
      #launcher.first_intercept_time,
      launcher.last_launch_time,
      #launcher.last_intercept_time,
      em_threat.impact_time,
      current_duration
    ]
    
    return border_times
  end ## def get_border_times
  
  
  ##############
  def get_deltas(launcher)
    used          = $sim_time.now
    border_times  = get_border_times(launcher)
    current_duration = EmTimeBarsController.get_current_duration
    deltas        = Array.new(border_times.length, 0.0)
    
    unless launcher.hit?
      border_times.each_with_index do |border_time, ind|
        unless ind == border_times.length - 1
          delta = border_time - used
          delta = 0.0 if delta < 0.0
          used += delta
          
          deltas[ind] = delta
        else
          deltas[ind] = current_duration - (used - $sim_time.now)
        end
      end
    else
      deltas[1] = current_duration
    end
    
    return deltas
  end ## def get_deltas
  
  
  ##################
  def cell_width_pct(delta)
    width = (delta / EmTimeBarsController.get_current_duration) * 100
    
    return "#{width <= 0 ? 0 : width}%"
  end ## def bar_pct(delta)
  
  
  ###################
  def get_cell_widths(launcher)
    cell_widths = Hash.new
    cell_labels = get_cell_labels
    deltas      = get_deltas(launcher)
    
    num = cell_labels.length
    
    num.times do |index|
      cell_widths[cell_labels[index]] = cell_width_pct(deltas[index])
    end
    
    return cell_widths
  end ## def get_cell_widths
  
  
  ##################
  # Each cell time is the current time until the border time
  def get_cell_times(launcher)
    cell_times    = Hash.new
    cell_labels   = get_cell_labels
    border_times  = get_border_times(launcher)
    
    num = cell_labels.length
    
    num.times do |index|
      cell_time = border_times[index] - $sim_time.now
      cell_time = 0 if cell_time < 0
      
      cell_times[cell_labels[index]] = cell_time
    end
    
    return cell_times
  end ## def get_cell_times
  
  
  ############################
  def get_bar_attributes(launcher)
    cell_labels = get_cell_labels
    cell_widths = get_cell_widths
    cell_times  = get_cell_times
    
    bar_attr = Array.new
    
    num = cell_labels.length
    
    num.times do |i|
      bar_attr << [cell_labels[i], cell_widths[i], deltas[i]]
    end
    
    return bar_attr
  end ## def get_td_percents(launcher)
  
end ## module EmTimeBarsHelper
