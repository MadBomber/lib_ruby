Trajectory Generators (Ruby)

This directory provides a set of Ruby classes for generating and processing trajectories:

  - abt_trajectory_generator.rb: AbtTrajectoryGenerator
      Generates an air-breathing, straight-line cruise trajectory with climb and descent phases.
  - trajectory_generator.rb: TrajectoryGenerator
      Generates a simple, zero-drag ballistic (parabolic) trajectory between two LLA points.
  - interceptor_generator.rb: InterceptorGenerator
      Solves for interceptor flight path given either time-of-flight or launch velocity.
  - idp_traj.rb: IdpTraj
      Reads an ECEF trajectory dump (from a file) and converts each point to LLA coordinates.
  - ephemeris_array.rb: EphemerisArray
      Utility for handling 4D (t,x,y,z) time-series data with linear interpolation.

Dependencies:
  - Ruby 2.x or later
  - LlaCoordinate (provides latitude/longitude/altitude to ECEF conversions)
  - Constants in scope: RAD_PER_DEG, DEG_PER_RAD, QUARTER_PI, WGS84.a, GRAVITY_MS2

Usage Examples:
  require_relative 'abt_trajectory_generator'
  generator = AbtTrajectoryGenerator.new([[lat1, lng1, alt1], [lat2, lng2, alt2]], velocity: 300, cruise_alt: 1000)
  generator.trajectory.each do |lla|
    puts "#{lla.lat}, #{lla.lng}, #{lla.alt}"
  end

  require_relative 'trajectory_generator'
  traj = TrajectoryGenerator.new(lla_start, lla_end, flight_time: 60, time_step: 0.5)
  traj.t_track.zip(traj.trajectory).each do |t, lla|
    puts "t=#{t}: #{lla.lat}, #{lla.lng}, #{lla.alt}"
  end

Please see each file’s class documentation for detailed options and methods.
