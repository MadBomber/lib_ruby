module RadarFarmModel

  def self.start_frame(a_header=nil, a_message=nil)
    
    $sim_time.advance_time

    $end_frame = EndFrame.new unless defined?($end_frame)
    $end_frame.publish
    
  end

end
