module BatteryFarmModel

  def self.start_frame(a_header=nil, a_message=nil)
    
    $sim_time.advance_time
    
    # NOTE: This model is message reqactive.  This means that start_frame
    #       is only used to advance the sim-wide time.  Current IseProtocol
    #       requires that an end_frame be sent back before any new start_frames
    #       can be sent.
    
    $end_frame = EndFrame.new unless defined?($end_frame)
    $end_frame.publish
    
  end

end
