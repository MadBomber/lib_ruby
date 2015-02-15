##########################################################
###
##  File: position_truth.rb
##  Desc: Handle the PositionTruth message
#

module Link16ToSimplejChannel

  ##################################################################################################
  # Called when a position truth message comes in (see init.rb)
  # May publish a "threat_warning" or "threat_detected" message
  # "threat_warning" is after '5' detects by ANY combination of radars (this emulates fusion?)
  # TODO:  When should the farm publish the "state" message for BMDFlex ?
  def self.simplej_space_track(a_header=nil, a_message=nil)
 
    log_message( a_header, a_message)

    a_message.msg_flag_mask_ = 0x00000008 | 0x00001000
    a_message.dest_id_ = 4   # hardcoded  to channel 4 
    a_message.publish


  end ## end of def self.position_truth(a_header=nil, a_message=nil)

end ## end of module Link16ToSimplejChannel





