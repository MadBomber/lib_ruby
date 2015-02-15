###############################################
###
##   File:   fe_messages_controller.rb
##   Desc:   Interface between ISE messages and ForceEffectiveness application.
##
#

class FeMessagesController < ApplicationController
  
  ##############################################################################
  ##                             Debugging Methods                            ##
  ##############################################################################
  
  # TODO: remove debugging methods when stable
  
  #########
  # Display all messages.
  # TODO: flesh this out
  def index
  end ## def index
  
    
  ##############################################
  # Add a message to the messages array. 
  def add_message(message_label, message_params)
    message = Struct.new(:label, :time, :params).new
  
    # store label
    message.label = message_label
  
    if message_params.include?('time_')
      # extract time from params
      message.time = message_params['time_']
      message_params.delete('time_')
    else
      message.time = nil
    end
  
    # store other params
    message.params  = message_params
    
    #pp message
  
    $fe_messages << message
  end ## def add_message(message_label, message_params)
  
  
  ########## VALID CODES ##########
  # ActionController::StatusCodes::SYMBOL_TO_STATUS_CODE =
  #  {:moved_permanently=>301,
  #   :gone=>410,
  #   :request_uri_too_long=>414,
  #   :request_timeout=>408,
  #   :non_authoritative_information=>203,
  #   :accepted=>202,
  #   :multi_status=>207,
  #   :upgrade_required=>426,
  #   :see_other=>303,
  #   :http_version_not_supported=>505,
  #   :created=>201,
  #   :multiple_choices=>300,
  #   :forbidden=>403,
  #   :proxy_authentication_required=>407,
  #   :not_extended=>510,
  #   :unsupported_media_type=>415,
  #   :im_used=>226,
  #   :internal_server_error=>500,
  #   :expectation_failed=>417,
  #   :processing=>102,
  #   :reset_content=>205,
  #   :not_implemented=>501,
  #   :unprocessable_entity=>422,
  #   :not_found=>404,
  #   :no_content=>204,
  #   :locked=>423,
  #   :not_acceptable=>406,
  #   :gateway_timeout=>504,
  #   :conflict=>409,
  #   :failed_dependency=>424,
  #   :length_required=>411,
  #   :use_proxy=>305,
  #   :ok=>200,
  #   :insufficient_storage=>507,
  #   :precondition_failed=>412,
  #   :temporary_redirect=>307,
  #   :requested_range_not_satisfiable=>416,
  #   :switching_protocols=>101,
  #   :continue=>100,
  #   :request_entity_too_large=>413,
  #   :bad_request=>400,
  #   :partial_content=>206,
  #   :bad_gateway=>502,
  #   :unauthorized=>401,
  #   :method_not_allowed=>405,
  #   :service_unavailable=>503,
  #   :not_modified=>304,
  #   :payment_required=>402,
  #   :found=>302}
  
  
  ##############################################################################
  ##                            Incoming Messages                             ##
  ##############################################################################
  
  ########################
  # Received an InterceptorHitTarget message from ISE.
  #   params: {'frame_count_', 'interceptor_label_', 'launcher_label_',
  #            'run_id_', 'threat_label_'}
  def InterceptorHitTarget
    begin
      add_message('InterceptorHitTarget', params)
      
      interceptor_info = {
        :label  => params['interceptor_label_'],
        :fe_run_id => params['run_id_'].to_i
      }
      
      FeInterceptorsController.interceptor_hit(interceptor_info)
      
      head :ok
    rescue
      $stderr.puts "InterceptorHitTarget failed: #{$!}"
      
      head :internal_server_error
    end
  end ## def InterceptorMissedTarget
  
  
  ###########################
  # Received an InterceptorMissedTarget message from ISE
  #   params: {'frame_count_', 'interceptor_label_', 'launcher_label_',
  #            'run_id_', 'threat_label_'}
  def InterceptorMissedTarget
    begin
      add_message('InterceptorMissedTarget', params)
      
      interceptor_info = {
        :label  => params['interceptor_label_'],
        :fe_run_id => params['run_id_'].to_i
      }
            
      FeInterceptorsController.interceptor_missed(interceptor_info)
      
      head :ok
    rescue
      $stderr.puts "InterceptorMissedTarget failed: #{$!}"
      
      head :internal_server_error
    end
  end ## def InterceptorMissedTarget
  
  
  ###############
  # Received a LauncherBid message from ISE.
  #   params: {'bid_factor_', 'first_intercept_time_', 'first_launch_time_',
  #            'frame_count_', 'last_intercept_time_', 'last_launch_time_',
  #            'launcher_label_', 'run_id_', 'threat_label_'}
  def LauncherBid
    begin
      add_message('LauncherBid', params)
            
      launcher_info = {
        :label  => params['launcher_label_'],
        :fe_run_id => params['run_id_'].to_i
      }
    
      FeLaunchersController.launcher_bid(launcher_info)
      
      head :ok
    rescue
      $stderr.puts "LauncherBid failed: #{$!}"
      
      head :internal_server_error
    end
  end ## def LauncherBid
  
  
  ##############
  # Received a StartFrame message from ISE.
  #   params: {'frame_count_', 'run_id_'}
  def StartFrame
    #begin
      add_message('StartFrame', params)
      
      run_info = {
        :frame => params['frame_count_'].to_i,
        :id    => params['run_id_'].to_i
      }
        
      FeRunsController.start_frame_received(run_info)
      
      head :ok
    #rescue
    #  $stderr.puts "StartFrame failed: #{$!}"
    #  
    #  head :internal_server_error
    #end
  end ## def StartFrame
  

  #########################
  # Received an AadseRunConfiguration message from ISE
  #   params: {'mp_scenario_id_', 'mp_tewa_configuration_id_', 'mps_name_',
  #            'mps_idp_name_', 'mps_sg_name_', 'mptc_name_'
  def AadseRunConfiguration
  
    add_message('AadseRunConfiguration', params)
    
    aadse_run_config = {
      :mps_idp_name => params['mps_idp_name_'],
      :mps_sg_name  => params['mps_sg_name_'],
      :mptc_name    => params['mptc_name_'],
      :id           => params['run_id_']
    }
    
    FeRunsController.aadse_run_config_received(aadse_run_config)
  
  end

  
  ########################
  # Received a TerminateInterceptor message from ISE.
  #   params = {'frame_count_', 'launcher_label_', 'interceptor_label_',
  #             'run_id_', 'self_destruct_', 'target_label_'}
  def TerminateInterceptor
    begin
      add_message('TerminateInterceptor', params)
      
      
      interceptor_info = {
        :label         => params['interceptor_label_'],
        :fe_run_id        => params['run_id_'].to_i,
        :self_destruct => (params['self_destruct_'].to_i == 1)
      }
            
      FeInterceptorsController.interceptor_terminated(interceptor_info)
      
      head :ok
    rescue
      $stderr.puts "TerminateInterceptor failed: #{$!}"
      
      head :internal_server_error
    end
  end
  
  
  ###################
  # Received a ThreatDestroyed message from ISE.
  #   params = {'frame_count_', 'run_id_', 'threat_label_'}
  def ThreatDestroyed
    begin
      add_message('ThreatDestroyed', params)
      
      
      threat_info = {
        :label  => params['threat_label_'],
        :fe_run_id => params['run_id_'].to_i
      }
            
      FeThreatsController.threat_destroyed(threat_info)
      
      head :ok
    rescue
      $stderr.puts "ThreatDestroyed failed: #{$!}"
      
      head :internal_server_error
    end
  end ## def ThreatDestroyed
  
  
  #################
  # Received a ThreatEngaged message from ISE.
  #   params = {'frame_count_', 'impact_time_', 'interceptor_label_',
  #             'launcher_label_', 'launch_time_', 'run_id_', 'threat_label_'}
  def ThreatEngaged
    begin
      add_message('ThreatEngaged', params)
          
      engagement_info = {
        :interceptor_label => params['interceptor_label_'],
        :launcher_label    => params['launcher_label_'],
        :fe_run_id            => params['run_id_'].to_i,
        :threat_label      => params['threat_label_']
      }
  
      FeEngagementsController.threat_engaged(engagement_info)
      
      head :ok
    rescue
      $stderr.puts "ThreatEngaged failed: #{$!}"
      
      head :internal_server_error
    end
  end ## def ThreatEngaged
  
  
  ##################
  # Received a ThreatImpacted message from ISE.
  #   params = {'frame_count_', 'run_id_', 'threat_label_', 'time_'}
  def ThreatImpacted
    begin
      add_message('ThreatImpacted', params)
  
      threat_info = {
        :label  => params['threat_label_'],
        :fe_run_id => params['run_id_'].to_i
      }
      
      FeThreatsController.threat_impacted(threat_info)
      
      head :ok
    rescue
      $stderr.puts "ThreatImpacted failed: #{$!}"
      
      head :internal_server_error
    end
  end ## def ThreatImpacted
  
  
  #################
  # Received a ThreatWarning message from ISE.
  #   params = {'defended_area_label_', 'frame_count_', 'impact_time_',
  #             'launch_area_label_', 'radar_label_', 'run_id_', 'threat_label_',
  #             'threat_type_'}
  def ThreatWarning
    begin
      add_message('ThreatWarning', params)
      
      threat_info = {
        :category    => params['threat_type_'],
        :label       => params['threat_label_'],
        :fe_run_id   => params['run_id_'].to_i,
        :source_area => params['launch_area_label_'],
        :target_area => params['defended_area_label_']
      }
  
      FeThreatsController.threat_detected(threat_info)
      
      head :ok
    rescue
      $stderr.puts "ThreatWarning failed: #{$!}"
      
      head :internal_server_error
    end
  end ## def ThreatWarning

end ## class FeMessagesController < ApplicationController
