require 'datetime_mods'

module InterceptorFarmModel

  ###############################################
  ## Process CancelEngageThreat messages
  
  def self.cancel_engage_threat(a_header, a_message=nil)

    threat_label    = a_message.threat_label_
    launcher_label  = a_message.launcher_label_
        
    ti = TerminateInterceptor.new
    ti.time_          = $sim_time.now
    ti.target_label_  = threat_label

    FARM.each_pair do |interceptor_label, rock|
    
      if rock.target_label == threat_label
      
        debug_me("CANCEL_OR_SUCIDE") {[:threat_label, :interceptor_label, :launcher_label, "$sim_time.sim_time", "rock.launch_time", "rock.impact_time"]}  if $debug
      
        
        if rock.impact_time.after $sim_time.sim_time
        
        
          if launcher_label.empty?
            
            # terminate all interceptors from all launchers
            ti.interceptor_label_         = interceptor_label
            ti.launcher_label_            = rock.launcher_label
            ti.self_destruct_             = rock.launch_time.before($sim_time.sim_time) ? 1 : 0 # TODO: higher fidelity requires a safe distance from launcher before self_destruct
            ti.publish
            
            debug_me('GENERIC'){"ti.self_destruct_"}  if $debug
          
          else
          
            if launcher_label == rock.launcher_label
              # terminate only interceptors from a specific launcher
              ti.interceptor_label_      = interceptor_label
              ti.launcher_label_         = rock.launcher_label
              ti.self_destruct_          = rock.launch_time.before($sim_time.sim_time)  ? 1 : 0 # TODO: higher fidelity requires a safe distance from launcher before self_destruct
              ti.publish
              
              debug_me('SPECIFIC'){"ti.self_destruct_"}  if $debug
              
            end
            
          end     ## end of if launcher_label.empty?
          
        end   ## end of if rock.impact_time.after $sim_time.sim_time
        
      end # end of if rock.target_label == threat_label
      
    end ## end of FARM.each_pair do |interceptor_label, rock|

  end ## end of def self.cancel_engage_threat(a_header, a_message=nil)

end ## end of module InterceptorFarmModel

