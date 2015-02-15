module InterceptorFarmModel

  def self.start_frame(a_header=nil, a_message=nil)
    
    # debug_me{"a_header.frame_count_"}
    
    $sim_time.advance_time
    
    # NOTE: This model is message re-active.  This means that start_frame
    #       is only used to advance the sim-wide time.  Current IseProtocol
    #       requires that an end_frame be sent back before any new start_frames
    #       can be sent.
    
    FARM.each_pair do |rock_label, rock|
        
      log_event "Launch #{rock_label}" if $sim_time.sim_time == rock.launch_time

      if rock.life_span.include? $sim_time.sim_time

        lla       = rock.current_position
        velocity  = rock.current_velocity
        attitude  = rock.current_attitude

        unless lla.nil?
          $position_truth.time_     = $sim_time.now
          $position_truth.label_    = rock_label
          $position_truth.position_ = lla.to_a
          $position_truth.velocity_ = velocity
          $position_truth.attitude_ = attitude
          $position_truth.publish
        end
      end
            
      if $sim_time.sim_time == rock.impact_time
        if 'hit' == rock.engagement_result
          log_event "Verified HIT #{rock_label}"
          FARM.delete(rock_label)
          $threat_destroyed.time_         = $sim_time.now
          $threat_destroyed.threat_label_ = rock.target_label
          $threat_destroyed.publish
          
          $interceptor_hit_target.time_               = $sim_time.now
          $interceptor_hit_target.threat_label_       = rock.target_label
          $interceptor_hit_target.interceptor_label_  = rock_label
          $interceptor_hit_target.launcher_label_     = rock.launcher_label
          $interceptor_hit_target.publish

        else
          log_event "Verified MISS #{rock_label}"
          
          $interceptor_missed_target.time_               = $sim_time.now
          $interceptor_missed_target.threat_label_       = rock.target_label
          $interceptor_missed_target.interceptor_label_  = rock_label
          $interceptor_missed_target.launcher_label_     = rock.launcher_label
          $interceptor_missed_target.publish

        end
        log_this "Interceptors left: #{FARM.length}"
      end
    end
    
    $end_frame = EndFrame.new unless defined?($end_frame)
    $end_frame.publish

    # The simulation contains only 1 InterceptorFarmModel
    # This model has the added responsibility of shutting down
    # the entire simulation by send out the end case and end run
    # messages.
    if $sim_time.end_of_sim?
      ec = EndCase.new
      ec.case_number_ = 1   # only 1 case in this simulation
      ec.publish
      EndRun.new.publish
    end


  end ## end of def self.start_frame(a_header=nil, a_message=nil)

end
