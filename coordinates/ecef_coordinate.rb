#############################
## Earth-Centered, Earth-Fixed
##
## Updated: Complete orthogonal coordinate conversions

require_relative 'geo_datum'

class EcefCoordinate
  attr_accessor :x, :y, :z

  def initialize(x = 0.0, y = 0.0, z = 0.0)
    if x.is_a?(Array)
      @x = x[0].to_f
      @y = x[1].to_f
      @z = x[2].to_f
    else
      @x = x.to_f
      @y = y.to_f
      @z = z.to_f
    end
  end

  # Convert to LLA coordinates
  def to_lla(datum = WGS84)
    require_relative 'lla_coordinate'
    
    a  = datum.a        # Semi-major axis
    e2 = datum.e2       # Eccentricity squared
    
    small_delta = 1e-12  # Convergence threshold

    longitude = Math.atan2(@y, @x)
    longitude_deg = longitude * DEG_PER_RAD

    # Iterative method for latitude and altitude
    p = Math.sqrt(@x**2 + @y**2)
    
    # Initial guess for latitude
    latitude = Math.atan2(@z, p * (1 - e2))
    altitude = 0.0
    
    max_iterations = 100
    iteration = 0
    
    loop do
      iteration += 1
      prev_latitude = latitude
      prev_altitude = altitude
      
      sin_lat = Math.sin(latitude)
      cos_lat = Math.cos(latitude)
      
      n = a / Math.sqrt(1 - e2 * sin_lat**2)
      altitude = (p / cos_lat) - n
      latitude = Math.atan2(@z, p * (1 - e2 * n / (n + altitude)))
      
      # Check convergence
      lat_diff = (latitude - prev_latitude).abs
      alt_diff = (altitude - prev_altitude).abs
      
      break if lat_diff < small_delta && alt_diff < small_delta
      break if iteration >= max_iterations
    end

    latitude_deg = latitude * DEG_PER_RAD
    LlaCoordinate.new(latitude_deg, longitude_deg, altitude)
  end

  # Create from LLA coordinates
  def self.from_lla(lla, datum = WGS84)
    require_relative 'lla_coordinate'
    raise ArgumentError, "Expected LlaCoordinate" unless lla.is_a?(LlaCoordinate)
    
    lla.to_ecef(datum)
  end

  # Convert to ENU coordinates relative to a reference ECEF point
  def to_enu(reference_ecef, reference_lla = nil)
    require_relative 'enu_coordinate'
    raise ArgumentError, "Expected EcefCoordinate" unless reference_ecef.is_a?(EcefCoordinate)
    
    # If reference LLA not provided, compute it
    if reference_lla.nil?
      require_relative 'lla_coordinate'
      reference_lla = reference_ecef.to_lla
    end
    
    # Calculate differences
    delta_x = @x - reference_ecef.x
    delta_y = @y - reference_ecef.y
    delta_z = @z - reference_ecef.z
    
    # Reference point's geodetic coordinates in radians
    lat_rad = reference_lla.lat * RAD_PER_DEG
    lon_rad = reference_lla.lng * RAD_PER_DEG
    
    sin_lat = Math.sin(lat_rad)
    cos_lat = Math.cos(lat_rad)
    sin_lon = Math.sin(lon_rad)
    cos_lon = Math.cos(lon_rad)
    
    # Transform to ENU coordinates
    e = -sin_lon * delta_x + cos_lon * delta_y
    n = -sin_lat * cos_lon * delta_x - sin_lat * sin_lon * delta_y + cos_lat * delta_z
    u = cos_lat * cos_lon * delta_x + cos_lat * sin_lon * delta_y + sin_lat * delta_z
    
    EnuCoordinate.new(e, n, u)
  end

  # Create from ENU coordinates relative to a reference point
  def self.from_enu(enu, reference_ecef, reference_lla = nil)
    require_relative 'enu_coordinate'
    raise ArgumentError, "Expected EnuCoordinate" unless enu.is_a?(EnuCoordinate)
    raise ArgumentError, "Expected EcefCoordinate" unless reference_ecef.is_a?(EcefCoordinate)
    
    enu.to_ecef(reference_ecef, reference_lla)
  end

  # Convert to NED coordinates relative to a reference ECEF point
  def to_ned(reference_ecef, reference_lla = nil)
    require_relative 'ned_coordinate'
    require_relative 'enu_coordinate'
    
    # Convert to ENU first, then to NED
    enu = self.to_enu(reference_ecef, reference_lla)
    enu.to_ned
  end

  # Create from NED coordinates relative to a reference point
  def self.from_ned(ned, reference_ecef, reference_lla = nil)
    require_relative 'ned_coordinate'
    raise ArgumentError, "Expected NedCoordinate" unless ned.is_a?(NedCoordinate)
    raise ArgumentError, "Expected EcefCoordinate" unless reference_ecef.is_a?(EcefCoordinate)
    
    ned.to_ecef(reference_ecef, reference_lla)
  end

  # Convert to UTM coordinates
  def to_utm(datum = WGS84)
    require_relative 'utm_coordinate'
    
    # Convert through LLA
    lla = self.to_lla(datum)
    lla.to_utm(datum)
  end

  # Create from UTM coordinates
  def self.from_utm(utm, datum = WGS84)
    require_relative 'utm_coordinate'
    raise ArgumentError, "Expected UtmCoordinate" unless utm.is_a?(UtmCoordinate)
    
    # Convert through LLA
    lla = utm.to_lla(datum)
    lla.to_ecef(datum)
  end

  # Utility methods
  def to_s
    "#{@x}, #{@y}, #{@z}"
  end

  def to_a
    [@x, @y, @z]
  end

  def ==(other)
    return false unless other.is_a?(EcefCoordinate)
    
    delta_x = (@x - other.x).abs
    delta_y = (@y - other.y).abs
    delta_z = (@z - other.z).abs
    
    delta_x <= 1e-6 && delta_y <= 1e-6 && delta_z <= 1e-6
  end

  # Calculate distance to another ECEF point
  def distance_to(other)
    raise ArgumentError, "Expected EcefCoordinate" unless other.is_a?(EcefCoordinate)
    
    dx = @x - other.x
    dy = @y - other.y
    dz = @z - other.z
    
    Math.sqrt(dx**2 + dy**2 + dz**2)
  end
end