module TrackToLink16

  def self.start_frame(a_header=nil, a_message=nil)
    
    $sim_time.advance_time

#    EventMachine::add_timer( 2.0 ) {
      $end_frame = EndFrame.new unless defined?($end_frame)
      $end_frame.publish
      debug_me "sent end_frame"  if $debug
#    }
    
  end

end
