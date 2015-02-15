##########################################################
###
##  File: position_truth.rb
##  Desc: Handle the PositionTruth message
#

module TrackToLink16

  ##################################################################################################
  # Called when a position truth message comes in (see init.rb)
  # May publish a "threat_warning" or "threat_detected" message
  # "threat_warning" is after '5' detects by ANY combination of radars (this emulates fusion?)
  # TODO:  When should the farm publish the "state" message for BMDFlex ?
  def self.position_truth(a_header=nil, a_message=nil)
 
    # Label is used to determine the threat type
    # TODO  what are the label possibilities and what if a nil label?
    threat_label  = a_message.label_

    # We only process active red and blue tracks. threat_warning creates
    # TODO create a factory to do this  
    if $active_tracks.include?(threat_label)
      threat_lla    = LlaCoordinate.new(a_message.position_)
      debug_me { [:threat_label, :threat_lla] }  if $debug
      $active_tracks[threat_label].lla = threat_lla
      log_this ">>>  Threat #{threat_label} is now active"
      create_send_link16(threat_label, a_message.velocity_, a_message.time_)
    else
      
      #  Blue assess are automatically added, this assummes perfect knowlege
      unless threat_label.is_red_force?
         if threat_label.is_missile?
          $active_tracks[threat_label] = Missile.new(threat_label)
        else
          $active_tracks[threat_label] = Aircraft.new(threat_label)
        end
        $active_tracks[threat_label].lla = LlaCoordinate.new(a_message.position_)
        create_send_link16(threat_label, a_message.velocity_, a_message.time_)
      end
    end

  end ## end of def self.position_truth(a_header=nil, a_message=nil)

end ## end of module TrackToLink16





