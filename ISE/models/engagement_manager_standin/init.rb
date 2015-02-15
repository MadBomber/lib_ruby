module EngagementManagerStandin

  ##########################################################
  ## init is invoked after a successful connections has been
  ## established with the IseDispatcher

  def self.init

    log_this "The #{self.name} has over-riden the Peerrb.init method" if $debug or $verbose

    ###########################################################
    ## Define some globals
        
    $active_threats     = Hash.new # key is threat_label; value is a threat object

    $threat_evaluation  = ThreatEvaluation.new

    
    ##########################################################
    ## Subscribe to IseRubyModel-specific messages

    ThreatWarning.subscribe(EngagementManagerStandin.method(:threat_warning))
    ThreatDestroyed.subscribe(EngagementManagerStandin.method(:remove_threat))
    ThreatImpacted.subscribe(EngagementManagerStandin.method(:remove_threat))




  ##############################################################################
  ## Control messages used with the FrameController and TimeController IseModels
  ## TODO: Move the subscriptions for standard messages to the Peerrb::register method
  ##       using standard callback methods based on the message name as snake case.

    StartFrame.subscribe(     EngagementManagerStandin.method(:start_frame))
    StatusRequest.subscribe(  EngagementManagerStandin.method(:status_request))
    InitCase.subscribe(       EngagementManagerStandin.method(:init_case))
    EndCase.subscribe(        EngagementManagerStandin.method(:end_case))
    EndRun.subscribe(         EngagementManagerStandin.method(:end_run))
    
    log_this "The subscribed hash:"

    $connection.subscribed.each_key do |k|
      begin
        amr = AppMessage.find(k)
      rescue
        amr = nil
      end
      log_this "#{k}). #{amr.app_message_key} -- #{amr.description}" unless amr.nil?
    end

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


