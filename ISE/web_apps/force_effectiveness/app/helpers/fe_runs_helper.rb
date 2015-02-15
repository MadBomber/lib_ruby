module FeRunsHelper
  def get_default_selected_label(a_query)
    #a_query[1]: entries
    #entries[0]: first entry
    #entry[0]:   entry label 
    
    return a_query[1][0][0]
  end
  
  
  ########################
  # Get the total run time in minutes for a particular run.
  def get_run_time
    run_time = (@fe_run.last_frame - @fe_run.first_frame).to_f / 60.0
    
    return sprintf("%.2f min", run_time)
  end ## def get_run_time(fe_run)
  
  def get_short_date
    time = @fe_run.created_at.localtime
    
    return "#{time.mon}-#{time.day}-#{time.year} #{time.hour}:#{time.min}"
  end
  
  def get_summary_table_data
      
    columns = [
      get_runs_summary,
      get_engagements_summary,
      get_threats_summary,
      get_interceptors_summary
    ]
    
    format_columns(columns)
    
    return columns
  end
  
  def format_columns(columns)
    match_column_sizes(columns)
    
    columns.each do |column|
      format_rows(column)
    end
  end
  
  def format_rows(column)
    column.each do |row|
      # Format the rows of the form: [category, value].
      if row.class == Array and row.size == 2
        # Skip if first element isn't a string
        next unless row[0].class == String
        
        # Append a ':' if none exists.
        row[0] << ':' unless /.*:$/.match row[0]
        
        # Format any floats as percentages.
        if row[1].class == Float
          row[1] = sprintf('%.2f%', row[1])
        end
      end
    end
  end
  
  def match_column_sizes(columns)
    max_size = get_max_column_size(columns)
        
    columns.each do |column|
      while column.size < max_size do
        column << nil
      end
    end
  end
  
  def get_max_column_size(columns)
    max_column_size = 0
        
    columns.each do |column|
      if max_column_size < column.size
        max_column_size = column.size
      end 
    end
    
    return max_column_size
  end
  
  def get_runs_summary
    run = [
      'Run',
      ['ID',          @fe_run.id],
      ['Date',        get_short_date],
      ['Run Time',    get_run_time],
      ['IDP Name',    @fe_run.mps_idp_name],
      ['SG Name',     @fe_run.mps_sg_name]
    ]
    
    return run
  end
  
  def get_engagements_summary
    engagements = [
      'Engagements',
      ['Total',    @eng_stats[:num]],
      ['Engaging', (@eng_stats[:pct_enga] + @eng_stats[:pct_pend])],
      ['Success',  @eng_stats[:pct_succ]],
      ['Failure',  @eng_stats[:pct_fail]],
      ['Cancel',   @eng_stats[:pct_canc]]
    ]
    
    return engagements
  end
  
  def get_threats_summary
    threats = [
      'Threats',
      #['Total',     @thr_stats[:num]],
      ['Air',       @thr_stats[:num_air]],
      ['Space',     @thr_stats[:num_spac]],
      ['Flying',    @thr_stats[:pct_flyi]],
      ['Killed', @thr_stats[:pct_dest]],
      ['Impacted',  @thr_stats[:pct_impa]]  
    ]
        
    return threats
  end
  
  def get_interceptors_summary
    interceptors = [
      'Interceptors',
      ['Total',      @int_stats[:num]],
      ['Engaging',   @int_stats[:pct_enga]],
      ['Canc + Term', @int_stats[:pct_term]],
      ['Hit',        @int_stats[:pct_hit]],
      ['Missed',     @int_stats[:pct_miss]]
    ]
    
    return interceptors
  end
end
