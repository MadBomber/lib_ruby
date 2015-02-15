################################################################################
## EmMessagesController
##
## This controller handles sending and receiving messages to and from ISE.

#  HTTP response codes
#
#  100 = :continue
#  101 = :switching_protocols
#  102 = :processing
#  200 = :ok
#  201 = :created
#  202 = :accepted
#  203 = :non_authoritative_information
#  204 = :no_content
#  205 = :reset_content
#  206 = :partial_content
#  207 = :multi_status
#  226 = :im_used
#  300 = :multiple_choices
#  301 = :moved_permanently
#  302 = :found
#  303 = :see_other
#  304 = :not_modified
#  305 = :use_proxy
#  307 = :temporary_redirect
#  400 = :bad_request
#  401 = :unauthorized
#  402 = :payment_required
#  403 = :forbidden
#  404 = :not_found
#  405 = :method_not_allowed
#  406 = :not_acceptable
#  407 = :proxy_authentication_required
#  408 = :request_timeout
#  409 = :conflict
#  410 = :gone
#  411 = :length_required
#  412 = :precondition_failed
#  413 = :request_entity_too_large
#  414 = :request_uri_too_long
#  415 = :unsupported_media_type
#  416 = :requested_range_not_satisfiable
#  417 = :expectation_failed
#  422 = :unprocessable_entity
#  423 = :locked
#  424 = :failed_dependency
#  426 = :upgrade_required
#  500 = :internal_server_error
#  501 = :not_implemented
#  502 = :bad_gateway
#  503 = :service_unavailable
#  504 = :gateway_timeout
#  505 = :http_version_not_supported
#  507 = :insufficient_storage
#  510 = :not_extended



## Outgoing Messages
require 'CancelEngageThreat'
require 'EngageThreat'
require 'PrepareToEngageThreat'

class EmMessagesController < ApplicationController
  
  ##############################################################################
  ##                             Debugging Methods                            ##
  ##############################################################################
  
  # TODO: remove debugging methods when stable
  
  #########
  def index
  end ## def index
  
    
  ##############################################
  def add_message(message_label, message_params)
  
    debug_me("MESSAGE_DEBUG"){[:message_label, :message_params]} if message_params.has_value?($debug_label)
  
    message = Struct.new(:label, :time, :params).new

    # store label
    message.label = message_label

    if message_params.include?('time_')
      # extract time from params
      message.time = message_params['time_']
      message_params.delete('time_')
    else
      message.time = $sim_time.now
    end

    # store other params
    message.params  = message_params

    $em_messages << message
  end ## def add_message(message_label, message_params)
  
  
  ##############################################
  def self.add_sent_threat_message(sent_message)
    message = Struct.new(:label, :time, :params).new
    
    message.label   = sent_message.class.to_s
    message.time    = sent_message.time_.to_f
    message.params  = {:threat_label_ => sent_message.threat_label_,
                       :launcher_label_ => sent_message.launcher_label_}
    
    $em_messages << message
  end ## def self.add_sent_threat_message(sent_message)
  
  
  def self.add_sent_prepare_message(sent_message)
    message = Struct.new(:label, :time, :params).new
        
    message.label   = sent_message.class.to_s
    message.time    = sent_message.time_.to_f
    message.params  = {:threat_label => sent_message.threat_label_}
    
    $em_messages << message
  end
  
  
  ##############################################################################
  ##                              General Methods                             ##
  ##############################################################################
  
  ####################
  def head_code(a_code = nil)
    codes = ActionController::StatusCodes::SYMBOL_TO_STATUS_CODE
    
    if codes.include?(a_code)
      head a_code
    else
      head :internal_server_error
    end
  end
  

  ##############################################################################
  ##                            Incoming Messages                             ##
  ##############################################################################



  ####################################
  # params = {'run_id_', 'mp_scenario_id_','mp_tewa_configuration_id_','sim_duration_',
  #           'mps_name_','mps_idp_name_','mps_sg_name_','mptc_name_'}


  def AadseRunConfiguration

    add_message('AadseRunConfiguration', params)
    
    $run_config = Hash.new unless defined?($run_config)
     
    $run_config = {
      'run_id'                    => params['run_id_'].to_i,
      'mp_scenario_id'            => params['mp_scenario_id_'].to_i,
      'mp_tewa_configuration_id'  => params['mp_tewa_configuration_id_'].to_i,
      'sim_duration'              => params['sim_duration_'].to_f,
      'mps_name'                  => params['mps_name_'],
      'mps_idp_name'              => params['mps_idp_name_'],
      'mps_sg_name'		            => params['mps_sg_name_'],
      'mptc_name'                 => params['mptc_name_']
    }
  
    $sim_time.duration = $run_config['sim_duration']
    
    head :ok

  end ## def AadseRunConfiguration







  ####################################
  # params = {'time_', 'first_launch_time_', 'first_intercept_time_',
  #           'last_launch_time_', 'last_intercept_time_', 'bid_factor_',
  #           'threat_label_', 'launcher_label_'}
  def LauncherBid
    # begin
      add_message('LauncherBid', params)
            
      launcher_info = {
        'label'                => params['launcher_label_'],
        'threat_label'         => params['threat_label_'],
        'battery_label'        => params['battery_label_'],
        'launcher_rounds_available' => params['launcher_rounds_available_'],
        'battery_rounds_available'  => params['battery_rounds_available_'],
        'bid'                  => params['bid_factor_'].to_f,
        'first_launch_time'		 => params['first_launch_time_'].to_f,
        'first_intercept_time' => params['first_intercept_time_'].to_f,
        'last_launch_time'     => params['last_launch_time_'].to_f,
        'last_intercept_time'	 => params['last_intercept_time_'].to_f,
      }
    
      threat_label = params['threat_label_']
    
      $em_threats[threat_label].engagement_protocol_progress  = EmThreat::ENGAGEMENT_PROTOCOL_STATES[:bid_received]
    
    
      EmThreatsController.launcher_bid_received(launcher_info)
      
      head :ok
    # rescue
    # puts "LauncherBid failed: #{$!}"
      
    #  head_code
    #end
  end ## def LauncherBid
  
  
  ########################
  # params = {'time_', 'threat_label_', 'launcher_label_',
  #           'interceptor_label_'}
  def InterceptorHitTarget
    # begin
      add_message('InterceptorHitTarget', params)
      
      interceptor_info = {
        'label'          => params['interceptor_label_'],
        'launcher_label' => params['launcher_label_'],
        'threat_label'   => params['threat_label_']
      }
    
      EmThreatsController.interceptor_hit(interceptor_info)
      
      head :ok
    #rescue
    #  puts "InterceptorHitTarget failed: #{$!}"
    #  
    #  head_code
    #end
  end ## def InterceptorHitTarget
  

  ###########################
  # params = {'time_', 'threat_label_', 'launcher_label_',
  #           'interceptor_label_'}
  def InterceptorMissedTarget
    #begin
      add_message('InterceptorMissedTarget', params)
      
      interceptor_info = {
        'label'          => params['interceptor_label_'],
        'launcher_label' => params['launcher_label_'],
        'threat_label'   => params['threat_label_']
      }
    
      EmThreatsController.interceptor_missed(interceptor_info)
      
      head :ok
    #rescue
    #  puts "InterceptorMissedTarget failed: #{$!}"
    #  
    #  head_code
    #end
  end ## def InterceptorMissedTarget
  

  ##############
  # params = {'frame_count_', 'run_id_'}
  def StartFrame
    #begin
      add_message('StartFrame', params)
  
      frame_count	= params['frame_count_'].to_i
      run_id      = params['run_id_']
        
      MainController.update_time(frame_count, run_id)
      
      head :ok
    #rescue
    #  puts "StartFrame failed: #{$!}"
    #  
    #  head_code
    #end
  end ## def StartFrame
  
  
  ########################
  # params = {'time_', 'target_label_', 'launcher_label_', 
  #           'interceptor_label_'}
  def TerminateInterceptor
    #begin
      add_message('TerminateInterceptor', params)
      
      interceptor_info = {
        'label'          => params['interceptor_label_'],
        'self_destruct'  => params['self_destruct_'],
        'launcher_label' => params['launcher_label_'],
        'threat_label'   => params['target_label_']
      }
      
      EmThreatsController.interceptor_terminated(interceptor_info)
      
      head :ok
    #rescue
    #  puts "TerminateInterceptor failed: #{$!}"
    #  
    #  head_code
    #end
  end
  

  #################
  # params = {'time_', 'launch_time_', 'impact_time_', 'threat_label_',
  #           'launcher_label_', 'interceptor_label_'}
  def ThreatEngaged
    #begin
      add_message('ThreatEngaged', params)
          
      interceptor_info = {
        'label'		       => params['interceptor_label_'],
        'launcher_label' => params['launcher_label_'],
        'threat_label'   => params['threat_label_'],
        'battery_label'  => params['battery_label_'],
        'launcher_rounds_available' => params['launcher_rounds_available_'],
        'battery_rounds_available'  => params['battery_rounds_available_'],
        'launch_time'    => params['launch_time_'].to_f,
        'intercept_time' => params['impact_time_'].to_f,
      }

      EmThreatsController.engaged(interceptor_info)
      
      head :ok
    #rescue
    #  puts "ThreatEngaged failed: #{$!}"
    #  
    #  head_code
    #end
  end ## def ThreatEngaged
  
  
  ##################
  # params = {'time_', 'threat_label_', 'priority_'}
  def ThreatEvaluation
    #begin
      add_message('ThreatEvaluation', params)
      
      threat_info = {
        'label'    => params['threat_label_'],
        'priority' => params['priority_'].to_f
      }
      
#      if threat_info['label'].nil?
#        puts "**********  ThreatEvaluation  **********"
#        pp threat_info
#      end
      
      EmThreatsController.update_priority(threat_info)
      
      head :ok
    #rescue
    #  puts "ThreatEvaluation failed: #{$!}"
    #  
    #  head_code
    #end
  end
  

  ##################
  # params = {'time_', 'threat_label_'}
  def ThreatImpacted
    #begin
      add_message('ThreatImpacted', params)
  
      threat_label = params['threat_label_']
      
      EmThreatsController.impacted(threat_label)
      
      head :ok
    #rescue
    #  puts "ThreatImpacted failed: #{$!}"
    #  
    #  head_code
    #end
  end ## def ThreatImpacted
  

  ####################
  # params = {'time_', 'threat_label_', 'launcher_label_'}
  def ThreatNotEngaged
    #begin
      add_message('ThreatNotEngaged', params)
  
      launcher_info = {
        'label'        => params['launcher_label_'],
        'threat_label' => params['threat_label_']
      }
      
      threat_label    = params['threat_label_']
      launcher_label  = params['launcher_label_']
      
      # an empty launcher label means that no launcher has an engagement zone on this threat
      # when a launcher_label is present, that generally signals a condition in which an engagement zone
      # existed and the user selected to engage; but, by the time the engagement order reached the launcher
      # the engagement zone no longer existed.
      if launcher_label.empty?
        $em_threats[threat_label].engagement_protocol_progress  = EmThreat::ENGAGEMENT_PROTOCOL_STATES[:cannot_engage]
      end
      
      EmThreatsController.engage_failed(launcher_info)
      
      head :ok
    #rescue
    #  puts "ThreatNotEngaged failed: #{$!}"
    #  
    #  head_code
    #end
  end ## def ThreatNotEngaged
  

  #################
  # params = {'time_', 'impact_time_', 'radar_label_', 'threat_label_',
  #           'defended_area_label_', 'launch_area_label_'}
  def ThreatWarning
    #begin
    
#      debug_me "ONE"
    
      add_message('ThreatWarning', params)
      
#      debug_me "TWO"
      
      threat_info = {
        'label'         => params['threat_label_'],
        'impact_time'		=> params['impact_time_'].to_f,
        'defended_area'	=> params['defended_area_label_'],
        'launch_area'		=> params['launch_area_label_']
      }

#      debug_me "THREE"

      EmThreatsController.add_threat(threat_info)
      
#      debug_me "FOUR"
      
      head :ok
    #rescue
    #  puts "ERROR ThreatWarning failed in #{__FILE__} Line #{__LINE__}: #{$!}"
    #  
    #  head_code
    #end
  end ## def ThreatWarning
      

  ##############################################################################
  ##                         Outgoing Class Messages                          ##
  ##############################################################################

  #############################################################
  # Output params = {'time_', 'threat_label_', 'launcher_label_'}
  def self.disengage_threat(threat_label, launcher_label = nil)
#    debug_me('MESSAGE_OUT')
    #begin
      cet = CancelEngageThreat.new
      
      self.send_engagement_message(cet, threat_label, launcher_label)
    #rescue
    #  puts "disengage_threat failed: #{$!}"
    #end
  end ## def disengage_threat(threat_label, launcher_label)
  

  ##################################
  # Output params = {'time_', 'threat_label_', 'launcher_label_'}
  def self.engage_threat(threat_label, launcher_label)

#    debug_me('MESSAGE_OUT')


    #begin
      et = EngageThreat.new
      
      self.send_engagement_message(et, threat_label, launcher_label)
    #rescue
    #  puts "engage_threat failed: #{$!}"
    #end
  end ## def engage_threat(threat_label, launcher_label)
  
  
  ###############################################
  # Output params = {'time_', 'threat_label_'}
  def self.prepare_to_engage_threat(threat_label)
  
#    debug_me(:file=>$stderr, :tag=>'MESSAGE_OUT')
    
    
    $em_threats[threat_label].engagement_protocol_progress  = EmThreat::ENGAGEMENT_PROTOCOL_STATES[:waiting]
    
    #begin
    
      message = PrepareToEngageThreat.new
      
      message.threat_label_ = threat_label
      
      self.send_message(message)
      
      self.add_sent_prepare_message(message)

    #rescue
    #  puts "prepare_to_engage_threat failed: #{$!}"      
    #end
  end
  
  
  ###########################################
  private # the following methods are private
  

  #######################################################################
  def self.send_engagement_message(message, threat_label, launcher_label)

#    debug_me(:file=>$stderr, :tag=>'MESSAGE_OUT')

    message.threat_label_ = threat_label
    message.launcher_label_ = launcher_label

    self.send_message(message)
    
    self.add_sent_threat_message(message)
  end ## def send_engagement_message(message, threat_label, launcher_label)
  

  ##############################
  def self.send_message(a_message)

#    debug_me(:file=>$stderr, :tag=>'MESSAGE_OUT')

    if a_message.respond_to?(:time_)
      a_message.time_ = $sim_time.now
    end

#    $dispatcher_connection.send_data(a_message.publish)


    begin
      ise_gateway = TCPSocket::new( ENV['ISE_WEBAPP_GATEWAY'], 8003 )
      
      puts "#{self.class} established TCP connection with #{ENV['ISE_WEBAPP_GATEWAY']}:8003" if $debug
      
    rescue Exception => e
      puts "ERROR: PortPublisher unable to open TCPSocket"
      puts "TCP Socket Error: #{e}"
      puts "       tcp_ip:    #{ENV['ISE_WEBAPP_GATEWAY']}"
      puts "       tcp_port:  8003"
      return false
    end

    data = a_message.publish    # returns binary data; IseMessage.publish is over-riden by OberridPeerrb

    begin
      ise_gateway.send(data, 0)
      puts "#{self.class} send to #{ENV['ISE_WEBAPP_GATEWAY']}:8003 this: #{data.to_hex}" if $debug
    rescue Exception => e
      puts "ERROR: Unable to send_message #{a_message.class}"
      puts "TCP Socket Error: #{e}"
      puts "       tcp_ip:    #{ENV['ISE_WEBAPP_GATEWAY']}"
      puts "       tcp_port:  8003"
      return false
    end

    ise_gateway.close
    
#    debug_me(:file=>$stderr, :tag=>'MESSAGE_OUT'){["a_message.class", "a_message"]}
    
    return true

  end ## def send_message(message)
  
  
  ##########################
  def self.capture_stdout(&block)
    original_stdout = $stdout
    original_stderr = $stderr
    
    $stdout = fake1 = StringIO.new
    $stderr = fake2 = stringIO.new
    
    begin
      yield
    ensure
      $stdout = original_stdout
      $stderr = original_stderr
    end
  end ## def capture_stdout(&block)

  
end ## class EmMessagesController < ApplicationController
