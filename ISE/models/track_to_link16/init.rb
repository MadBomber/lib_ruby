module TrackToLink16

  # TODO  JKL note for other developers
  #   If you use ## in the comments then Eclipse cannot pull out the TODO's
  
  ##########################################################
  # init is invoked after a successful connections has been
  # established with the IseDispatcher
  # TODO  ISE 2.0 note:  there will and 'init' and 'provision' call due to way that ACE loades dlls
  #   the first init is mostly to setup the database...the model number will not be known until the final 'upcall'
  #   on the C++ side.  The 'provision' call is where the message subscriptions will take place in the C++ models
  def self.init

    log_this "The #{self.name} has over-riden the Peerrb.init method" if $debug or $verbose

    ##########################################################
    # Declare global variables
    # TODO  This SMELLS! Modules are NOT Classes, so no "module instance variables".

    # Hash of threat objects where the key is a threat_label
    $active_tracks   = Hash.new 

    ##########################################################
    # Subscribe to IseRubyModel-specific messages
    # TODO JKL this SMELLS of global variables! (sending a subscribe to a class, but could be a factory pattern)

    PositionTruth.subscribe( TrackToLink16.method(:position_truth))
    ThreatWarning.subscribe( TrackToLink16.method(:threat_warning))
    ThreatImpacted.subscribe( TrackToLink16.method(:remove_active_threat))
    ThreatDestroyed.subscribe( TrackToLink16.method(:remove_active_threat))

    ##############################################################################
    # Control messages used with the FrameController and TimeController IseModels
    # TODO: Move the subscriptions for standard messages to the Peerrb::register method
    #       using standard callback methods based on the message name as snake case.
    # TODO:  JKL  I disagree with the above TODO, Peerrb is the base class, these are specifice to the Samson model, which is a Framed model
    
    #StartFrame.subscribe(     TrackToLink16.method(:start_frame))
    StatusRequest.subscribe(  TrackToLink16.method(:status_request))
    InitCase.subscribe(       TrackToLink16.method(:init_case))
    EndCase.subscribe(        TrackToLink16.method(:end_case))
    EndRun.subscribe(         TrackToLink16.method(:end_run))

    log_this "The subscribed hash:"

    $connection.subscribed.each_key do |k|
      begin
        amr = AppMessage.find(k)
      rescue
        amr = nil
      end
      log_this "#{k}). #{amr.app_message_key} -- #{amr.description}" unless amr.nil?
    end

    #  AdvanceTimeRequest.subscribe(TrackToLink16::MonteCarlo.method(:step))

    #  AdvanceTime.subscribe(TrackToLink16.method(:log_message))

    if $running_in_the_peer
      # output something to let the user known this IseRubyModel is still alive
      EventMachine::add_periodic_timer( 30 ) do
        puts "-"*30
        puts "#{__FILE__}:  #{Time.now}" ## every 30 seconds
        $stdout.flush
      end
    end
    
    # TODO How to I get this to put 0 here to keep it out of the StartFrame/EndFrame loop
    # Establish the rate at which this IseRubyModel desires to be stroked
    Peerrb.rate= 0.0

    # Tell the IseRubyPeer that this IseRubyModel is ready to run ......
    Peerrb.model_ready

  end ## end of self.init

end

