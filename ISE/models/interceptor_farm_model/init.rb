module InterceptorFarmModel

  ##########################################################
  ## init is invoked after a successful connections has been
  ## established with the IseDispatcher

  def self.init

    log_this "The #{self.name} has over-riden the Peerrb.init method" if $debug or $verbose
    
    $interceptor_threat_xref = Hash.new # key is interceptor_label; value is threat_label
    
    ##########################################################
    ## Subscribe to IseRubyModel-specific messages
    
    $position_truth             = PositionTruth.new
    $threat_destroyed           = ThreatDestroyed.new
    $interceptor_hit_target     = InterceptorHitTarget.new
    $interceptor_missed_target  = InterceptorMissedTarget.new
    
    ThreatDestroyed.subscribe(InterceptorFarmModel.method(:threat_destroyed))
    WarmUpInterceptor.subscribe(InterceptorFarmModel.method(:warm_up_interceptor))
    TerminateInterceptor.subscribe(InterceptorFarmModel.method(:terminate_interceptor))
    CancelEngageThreat.subscribe(InterceptorFarmModel.method(:cancel_engage_threat))


  ##############################################################################
  ## Control messages used with the FrameController and TimeController IseModels
  ## TODO: Move the subscriptions for standard messages to the Peerrb::register method
  ##       using standard callback methods based on the message name as snake case.

    StartFrame.subscribe(     InterceptorFarmModel.method(:start_frame))
    StatusRequest.subscribe(  InterceptorFarmModel.method(:status_request))
    InitCase.subscribe(       InterceptorFarmModel.method(:init_case))
    EndCase.subscribe(       InterceptorFarmModel.method(:end_case))
    EndRun.subscribe(         InterceptorFarmModel.method(:end_run))
    
    log_this "The subscribed hash:"

    $connection.subscribed.each_key do |k|
      begin
        amr = AppMessage.find(k)
      rescue
        amr = nil
      end
      log_this "#{k}). #{amr.app_message_key} -- #{amr.description}" unless amr.nil?
    end
    
  #  AdvanceTimeRequest.subscribe(InterceptorFarmModel::MonteCarlo.method(:step))

  #  AdvanceTime.subscribe(InterceptorFarmModel.method(:log_message))

    if $running_in_the_peer
      # output something to let the user known this IseRubyModel is still alive
      EventMachine::add_periodic_timer( 30 ) do
        puts "-"*30
        puts "#{__FILE__}:  #{Time.now}" ## every 30 seconds
        $stdout.flush
      end
    end
    # Establish the rate at which this IseRubyModel desires to be stroked
    Peerrb.rate= $sim_time.step_seconds
    
    # Tell the IseRubyPeer that this IseRubyModel is ready to run ......
    Peerrb.model_ready

  end ## end of self.init

end


