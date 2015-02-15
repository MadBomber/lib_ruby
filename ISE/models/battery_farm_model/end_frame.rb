module BatteryFarmModel

  def self.end_frame(a_header=nil, a_message=nil)
    puts "end_frame"
    EndFrameOkResponse.publish
  end

end
