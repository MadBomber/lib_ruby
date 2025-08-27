 # Trajectory Generators (Ruby)

 This directory provides a set of Ruby classes for generating and processing trajectories:

 ## Generators
 - **AbtTrajectoryGenerator** (`abt_trajectory_generator.rb`)
   - Generates an air-breathing target (ABT) trajectory: straight path with climb and descent phases.
 - **TrajectoryGenerator** (`trajectory_generator.rb`)
   - Creates a parabolic ballistic trajectory (zero drag) between two LLA points.
 - **InterceptorGenerator** (`interceptor_generator.rb`)
   - Solves for an interceptor flight path given either time-of-flight or launch velocity.
 - **IdpTraj** (`idp_traj.rb`)
   - Reads an ECEF trajectory dump from a file and converts each point to LLA coordinates.
 - **EphemerisArray** (`ephemeris_array.rb`)
   - Utility for handling 4D (t, x, y, z) time-series data with linear interpolation.

 ## Dependencies
 - Ruby 2.x or later
 - `LlaCoordinate` (provides LLA ↔ ECEF conversions)
 - Global constants in scope: `RAD_PER_DEG`, `DEG_PER_RAD`, `QUARTER_PI`, `WGS84.a`, `GRAVITY_MS2`

 ## Usage Examples

 ### ABT Trajectory
 ```ruby
 require_relative 'abt_trajectory_generator'

 generator = AbtTrajectoryGenerator.new(
   [[lat1, lng1, alt1], [lat2, lng2, alt2]],
   velocity: 300,       # meters/second
   cruise_alt: 1000,    # meters
   time_step: 1.0       # seconds
 )

 generator.t_track.zip(generator.trajectory).each do |t, lla|
   puts "t=#{t}: lat=#{lla.lat}, lng=#{lla.lng}, alt=#{lla.alt}"
 end
 ```

 ### Ballistic Trajectory
 ```ruby
 require_relative 'trajectory_generator'

 traj = TrajectoryGenerator.new(
   lla_start,           # LlaCoordinate for launch point
   lla_end,             # LlaCoordinate for impact point
   flight_time: 60.0,   # seconds
   time_step: 0.5       # seconds
 )

 traj.t_track.zip(traj.trajectory).each do |t, lla|
   puts "t=#{t}: lat=#{lla.lat}, lng=#{lla.lng}, alt=#{lla.alt}"
 end
 ```

 Additional options and detailed method documentation are available in each class file.