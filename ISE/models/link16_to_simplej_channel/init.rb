module Link16ToSimplejChannel

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
    # XXX sends a subscribe to a class, but could be a factory pattern)

    SimpleJAirTrack.subscribe( Link16ToSimplejChannel.method(:simplej_air_track))
    SimpleJSpaceTrack.subscribe( Link16ToSimplejChannel.method(:simplej_space_track))

    ##############################################################################
    # Control messages used with the FrameController and TimeController IseModels
    # TODO: Create mixin to handle this

    StatusRequest.subscribe(  Link16ToSimplejChannel.method(:status_request))
    InitCase.subscribe(       Link16ToSimplejChannel.method(:init_case))
    EndCase.subscribe(        Link16ToSimplejChannel.method(:end_case))
    EndRun.subscribe(         Link16ToSimplejChannel.method(:end_run))

    log_this "The subscribed hash:"

    $connection.subscribed.each_key do |k|
      begin
        amr = AppMessage.find(k)
      rescue
        amr = nil
      end
      log_this "#{k}). #{amr.app_message_key} -- #{amr.description}" unless amr.nil?
    end

    #  AdvanceTimeRequest.subscribe(Link16ToSimplejChannel::MonteCarlo.method(:step))

    #  AdvanceTime.subscribe(Link16ToSimplejChannel.method(:log_message))

    if $running_in_the_peer
      # output something to let the user known this IseRubyModel is still alive
      EventMachine::add_periodic_timer( 30 ) do
        puts "-"*30
        puts "#{__FILE__}:  #{Time.now}" ## every 30 seconds
        $stdout.flush
      end
    end

    # Establish the rate at which this IseRubyModel desires to be stroked
    Peerrb.rate= 0.0

    # Tell the IseRubyPeer that this IseRubyModel is ready to run ......
    Peerrb.model_ready

  end ## end of self.init

end

