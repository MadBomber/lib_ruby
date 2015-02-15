module RadarFarmModel

  ##########################################################
  ## init is invoked after a successful connections has been
  ## established with the IseDispatcher

  def self.init

    log_this "The #{self.name} has over-riden the Peerrb.init method" if $debug or $verbose
    
    $active_threats   = Hash.new # key is threat_label; value is a threat object
    $detected_threats = Hash.new # key is [radar_label][threat_label]; value is detection count
    
    FARM.each_key do |k|
      $detected_threats[k] = Hash.new
    end
    
    ##########################################################
    ## Subscribe to IseRubyModel-specific messages

    $threat_position  = ThreatPosition.new
    $threat_detected  = ThreatDetected.new
    $threat_warning   = ThreatWarning.new



    PositionTruth.subscribe(RadarFarmModel.method(:position_truth))

  ##############################################################################
  ## Control messages used with the FrameController and TimeController IseModels
  ## TODO: Move the subscriptions for standard messages to the Peerrb::register method
  ##       using standard callback methods based on the message name as snake case.

    StartFrame.subscribe(     RadarFarmModel.method(:start_frame))
    StatusRequest.subscribe(  RadarFarmModel.method(:status_request))
    InitCase.subscribe(       RadarFarmModel.method(:init_case))
    EndCase.subscribe(        RadarFarmModel.method(:end_case))
    EndRun.subscribe(         RadarFarmModel.method(:end_run))
    
    log_this "The subscribed hash:"

    $connection.subscribed.each_key do |k|
      begin
        amr = AppMessage.find(k)
      rescue
        amr = nil
      end
      log_this "#{k}). #{amr.app_message_key} -- #{amr.description}" unless amr.nil?
    end
    
  #  AdvanceTimeRequest.subscribe(RadarFarmModel::MonteCarlo.method(:step))

  #  AdvanceTime.subscribe(RadarFarmModel.method(:log_message))

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


