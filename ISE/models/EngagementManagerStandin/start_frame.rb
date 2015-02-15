module EngagementManagerStandin

  def self.start_frame(a_header=nil, a_message=nil)

    $arc.publish if 0.0 == $sim_time.now
    
    $sim_time.advance_time
    
    if 0 == $sim_time.now.to_i % 10   # Re-evaluate every 10 seconds

      $active_threats.each_pair do |threat_label, bully|
      
        unless bully.impact_time >= $sim_time.now
        
          most_important_defended_area  = bully.threat_to[0]
          most_important_launch_area    = bully.launch_area_label[0]
          
          threat_value  = update_threat_priority(bully)
          
          unless threat_value < 0.0 
            $threat_evaluation.time_                = $sim_time.now
            $threat_evaluation.threat_label_        = threat_label
            $threat_evaluation.threat_type_         = bully.type
            $threat_evaluation.defended_area_label_ = most_important_defended_area
            $threat_evaluation.launch_area_label_   = most_important_launch_area
            $threat_evaluation.impact_time_         = bully.impact_time
            $threat_evaluation.priority_            = threat_value
            $threat_evaluation.publish
          end
        
        end
                
      end
    
    end

    $end_frame = EndFrame.new unless defined?($end_frame)
    $end_frame.publish

  end ## end of def self.start_frame(a_header=nil, a_message=nil)

end ## end of module EngagementManagerStandin

