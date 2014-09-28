#################################################################
###
##  File: IdpTraj.rb
##  Desc: A short range thing
#

require 'pathname'
require 'LlaCoordinate'

class IdpTraj

  attr_reader   :pathname_
  attr_reader   :t_track
  attr_accessor :trajectory

  def initialize( filename = nil, launch_time = 0)

    raise "InvalidFileName: no filename was provided" if filename.nil?

    case filename.class.to_s
    when 'String' then
      @pathname_ = Pathname.new filename
    when 'Pathname' then
      @pathname_ = filename
    else
      raise "InvalidFileName: filename class not string or pathname."
    end

    raise "InvalidFileName: filename does not exist." unless @pathname_.exist?

    earth_radius = 6373000.0 

    
    # Read in the data from the traj_rv.txt file
    data_array = Array.new
    traj_file = File.open( @pathname_.to_s, 'r')

    while (a_line = traj_file.gets)
      data_array << a_line.split(' ') unless a_line.nil?
    end
  
    traj_file.close


    @t_track                = Array.new
    @trajectory             = Array.new
    @velocity_vector_track  = Array.new
    @attitude_vector_track  = Array.new

    # Go through each line, select the lines with trajectory data, and write to the appropriate variables
    data_array.each do |a_line|
      
      unless a_line[0].nil?

        if ("0".."9").include?(a_line[0][0]) # FIXME: this is a weird way to do this

          time = a_line[0].to_f.ceil.to_f + launch_time

          x_ecef = a_line[1].to_f
          y_ecef = a_line[2].to_f
          z_ecef = a_line[3].to_f

          x_velocity = a_line[4].to_f
          y_velocity = a_line[5].to_f
          z_velocity = a_line[6].to_f

          velocity = a_line[12].to_f

          x_attitude = x_velocity / velocity
          y_attitude = y_velocity / velocity
          z_attitude = z_velocity / velocity

          lng = Math.atan2( y_ecef, x_ecef) * 180.0 /3.14159
          lat = Math.atan2( z_ecef, Math.sqrt(x_ecef**2 + y_ecef**2)) * 180.0 /3.14159
          alt = Math.sqrt( x_ecef**2 + y_ecef**2 + z_ecef**2) - earth_radius #FIXME: Replace earth_radius with a function of the radius of the earth based on latitude

          @t_track                << time
          @trajectory             << LlaCoordinate.new( lat, lng, alt)
          @velocity_vector_track  << [ x_velocity, y_velocity, z_velocity]
          @attitude_vector_track  << [ x_attitude, y_attitude, z_attitude]
          

        end
      end

    end ## end of data_array.each do |a_line|
             


  end ## end of def initialize(filename)
  
  
  ################################
  def write_to_file(file_name)

    file_out = File.new(file_name.to_s,  "w")

    # write each trajectory point with a time offset beginning at launch_time to the traj file
    time_offset = 0
    @trajectory.each do |a_point|

      file_out.printf("%f,%f,%f,%f,%f,%f,%f,%f,%f,%f\n",
        @t_track[time_offset],
        a_point.lat,
        a_point.lng,
        a_point.alt,
        @velocity_vector_track[time_offset][0],
        @velocity_vector_track[time_offset][1],
        @velocity_vector_track[time_offset][2],
        @attitude_vector_track[time_offset][0],
        @attitude_vector_track[time_offset][1],
        @attitude_vector_track[time_offset][2]
      )


      time_offset += 1

    end ## end of @trajectory.each do |a_point|

    file_out.close     # close traj the file

  end ## end of def write_to_file(which_file)

  def usable?

    @trajectory.each do |a_point|
      if a_point.alt > 1000000.0
        return false
      end
    end

    return true

  end ## end of def usable?

end ## end of class IdpTraj
