module BatteryFarmModel

  ##########################################################
  ## init is invoked after a successful connections has been
  ## established with the IseDispatcher

  def self.init

    log_this "The #{self.name} has over-riden the Peerrb.init method" if $debug or $verbose
    
    ##########################################################
    ## Subscribe to IseRubyModel-specific messages    
    
    ThreatWarning.subscribe(          BatteryFarmModel.method(:threat_warning))
    PrepareToEngageThreat.subscribe(  BatteryFarmModel.method(:prepare_to_engage_threat))
    EngageThreat.subscribe(           BatteryFarmModel.method(:engage_threat))
    CancelEngageThreat.subscribe(     BatteryFarmModel.method(:cancel_engage_threat))
    
    ThreatImpacted.subscribe(         BatteryFarmModel.method(:remove_active_threat))
    ThreatDestroyed.subscribe(        BatteryFarmModel.method(:remove_active_threat))
    

  ##############################################################################
  ## Control messages used with the FrameController and TimeController IseModels
  ## TODO: Move the subscriptions for standard messages to the Peerrb::register method
  ##       using standard callback methods based on the message name as snake case.

    StartFrame.subscribe(     BatteryFarmModel.method(:start_frame))
    StatusRequest.subscribe(  BatteryFarmModel.method(:status_request))
    InitCase.subscribe(       BatteryFarmModel.method(:init_case))
    EndCase.subscribe(        BatteryFarmModel.method(:end_case))
    EndRun.subscribe(         BatteryFarmModel.method(:end_run))
    
    log_this "The subscribed hash:"

    $connection.subscribed.each_key do |k|
      begin
        amr = AppMessage.find(k)
      rescue
        amr = nil
      end
      log_this "#{k}). #{amr.app_message_key} -- #{amr.description}" unless amr.nil?
    end
    
  #  AdvanceTimeRequest.subscribe(Peerrb::MonteCarlo.method(:step))

  #  AdvanceTime.subscribe(BatteryFarmModel.method(:log_message))


    # output something to let the user known this IseRubyModel is still alive
    EventMachine::add_periodic_timer( 30 ) do
      puts "-"*30
      puts "#{__FILE__}:  #{Time.now}" ## every 30 seconds
      $stdout.flush
    end

    # Establish the rate at which this IseRubyModel desires to be stroked
    Peerrb.rate= $sim_time.step_seconds
    
    # Tell the IseRubyPeer that this IseRubyModel is ready to run ......
    Peerrb.model_ready

  end ## end of self.init

end


