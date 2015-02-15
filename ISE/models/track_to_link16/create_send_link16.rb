module TrackToLink16

  require 'GeoDatum'
  require 'SimpleJSpaceTrack'
  require 'SimpleJAirTrack'

  ###############################################################
  ## Create and Send a Link16 SpaceTrack or AirTrack message
  ## over the ISE Network tunneled with a SamsonHeader
  ## input parameter is the threat_label and used the global $active_tracks
  ## Note this relies on this object filling out the whole message

  def self.create_send_link16( _threat_label, _velocity_vector, _time)

    # TODO This SMELLS. I should key off of type and make the things a passed in reference. Globals can be an issue.

    if _threat_label.is_missile?

      sjm_st = SimpleJSpaceTrack.new
      sjm_st.simplej_header.sequence_num_  = 0
      #sjm_st.simplej_header.transit_time_  = 0
      sjm_st.simplej_header.transit_time_  = _time
      sjm_st.link16_message.minute_        = Integer(_time / 60)
      sjm_st.link16_message.second_        = Integer(_time) - 60 * sjm_st.link16_message.minute_

      #  TODO  'is_X_force?' being a method on a string causes me a twitch as it puts a behavior on a string, not the type of thing it is.

      sjm_st.link16_message.identity_ = 0  ## 0=yellow(pending); 3=blue; 6=red
      sjm_st.link16_message.identity_ = 3  if $active_tracks[_threat_label].label.is_blue_force?
      sjm_st.link16_message.identity_ = 6  if $active_tracks[_threat_label].label.is_red_force?
      sjm_st.link16_message.track_number_reference_ = Link16Message.encode_track_id( $active_tracks[_threat_label].track_id)

      ecef_coord  = $active_tracks[_threat_label].lla.to_ecef   # NOTE: ecef units in meters

      x           = (ecef_coord.x / 0.3048).to_i   # x,y,z in meters converting to feet
      y           = (ecef_coord.y / 0.3048).to_i
      z           = (ecef_coord.z / 0.3048).to_i
      
      vx          = 0 # _velocity_vector[0]   # in meters per second
      vy          = 0 # _velocity_vector[1]
      vz          = 0 # _velocity_vector[2]

      sjm_st.simplej_header.sequence_num_ += 1

      sjm_st.link16_message.x_position_  = SpaceTrack.scale(x, 0.1, 0x800000).to_i
      sjm_st.link16_message.y_position_  = SpaceTrack.scale(y, 0.1, 0x800000).to_i
      sjm_st.link16_message.z_position_  = SpaceTrack.scale(z, 0.1, 0x800000).to_i

      sjm_st.link16_message.x_velocity_  = SpaceTrack.scale(vx, 1.0, 0x4000).to_i
      sjm_st.link16_message.y_velocity_  = SpaceTrack.scale(vy, 1.0, 0x4000).to_i
      sjm_st.link16_message.z_velocity_  = SpaceTrack.scale(vz, 1.0, 0x4000).to_i
      sjm_st.pack_message
      
      #sjm_st.msg_flag_mask_ = 0x00000008 | 0x00001000
      #sjm_st.dest_id_ = 4   # hardcoded  to channel 4 

      sjm_st.publish

    else  #Aircraft or CM

      #  ARRRG no static method variables, and since modules are not classes...hmmmm
      $silly_static_sjm_counter = 0
      
      sjm_air = SimpleJAirTrack.new 
      sjm_air.link16_message.identity_amplifying_descriptor_ = 0  ## 0=yellow(pending); 3=blue; 6=red
      sjm_air.link16_message.identity_amplifying_descriptor_ = 3  if name.is_blue_force?
      sjm_air.link16_message.identity_amplifying_descriptor_ = 6  if name.is_red_force?

      case $active_tracks[_threat_label].type
      when 'UAV' then
        sjm_air.link16_message.air_platform_           =  5 # Recon
      when 'C' then
        sjm_air.link16_message.air_platform_           = 10 # Transport
      when 'R' then
        sjm_air.link16_message.air_platform_           = 16 # AWACS
      when 'CM' then
        sjm_air.link16_message.air_platform_           = 44 # Cruise Missile
      else
        sjm_air.link16_message.air_platform_           =  0 # No Statement
      end

      sjm_air.simplej_header.sequence_num_ = $silly_static_sjm_counter++
      sjm_air.link16_message.track_number_reference_ =  Link16Message.encode_track_id( $active_tracks[_threat_label].track_id)
      sjm_air.link16_message.set_lla( $active_tracks[_threat_label].lla)  # TODO no velocity information ???
      sjm_air.pack_message
      
      #sjm_air.msg_flag_mask_ = 0x00000008 | 0x00001000
      #sjm_air.dest_id_ = 4   # hardcoded  to channel 4 

      sjm_air.publish

    end

  end ## create_send_link16

end
