module Link16ToSimplejChannel
  
  ###############################################
  ## A generic callback to dump incoming messages
  def self.simplej_air_track( a_header, a_message=nil)

    log_message( a_header, a_message)

    #  TODO:  evaluate all the packing/unpacking
    a_message.msg_flag_mask_ = 0x00000008 | 0x00001000
    a_message.dest_id_ = 4   # hardcoded  to channel 4 
    a_message.publish

  end ## end of def self.threat_warning(a_header, a_message=nil)

end ## end of module Link16ToSimplejChannel
