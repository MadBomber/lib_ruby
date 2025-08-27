##################
## East, North, Up
##
## Updated: Complete orthogonal coordinate conversions

require_relative 'geo_datum'

class EnuCoordinate
  attr_accessor :e, :n, :u
  alias_method :east, :e
  alias_method :north, :n
  alias_method :up, :u

  def initialize(e = 0.0, n = 0.0, u = 0.0)
    if e.is_a?(Array)
      @e = e[0].to_f
      @n = e[1].to_f
      @u = e[2].to_f
    else
      @e = e.to_f
      @n = n.to_f
      @u = u.to_f
    end
  end

  # Convert to ECEF coordinates relative to a reference point
  def to_ecef(reference_ecef, reference_lla = nil)
    require_relative 'ecef_coordinate'
    raise ArgumentError, "Expected EcefCoordinate" unless reference_ecef.is_a?(EcefCoordinate)
    
    # If reference LLA not provided, compute it
    if reference_lla.nil?
      require_relative 'lla_coordinate'
      reference_lla = reference_ecef.to_lla
    end
    
    # Reference point's geodetic coordinates in radians
    lat_rad = reference_lla.lat * RAD_PER_DEG
    lon_rad = reference_lla.lng * RAD_PER_DEG
    
    sin_lat = Math.sin(lat_rad)
    cos_lat = Math.cos(lat_rad)
    sin_lon = Math.sin(lon_rad)
    cos_lon = Math.cos(lon_rad)
    
    # Transform ENU to ECEF deltas
    delta_x = -sin_lon * @e - sin_lat * cos_lon * @n + cos_lat * cos_lon * @u
    delta_y = cos_lon * @e - sin_lat * sin_lon * @n + cos_lat * sin_lon * @u
    delta_z = cos_lat * @n + sin_lat * @u
    
    # Add to reference ECEF coordinates
    x = reference_ecef.x + delta_x
    y = reference_ecef.y + delta_y
    z = reference_ecef.z + delta_z
    
    EcefCoordinate.new(x, y, z)
  end

  # Create from ECEF coordinates relative to a reference point
  def self.from_ecef(ecef, reference_ecef, reference_lla = nil)
    require_relative 'ecef_coordinate'
    raise ArgumentError, "Expected EcefCoordinate" unless ecef.is_a?(EcefCoordinate)
    raise ArgumentError, "Expected EcefCoordinate" unless reference_ecef.is_a?(EcefCoordinate)
    
    ecef.to_enu(reference_ecef, reference_lla)
  end

  # Convert to NED coordinates (simple coordinate swap)
  def to_ned
    require_relative 'ned_coordinate'
    
    # ENU to NED: E->E, N->N, U->-D
    NedCoordinate.new(@n, @e, -@u)
  end

  # Create from NED coordinates
  def self.from_ned(ned)
    require_relative 'ned_coordinate'
    raise ArgumentError, "Expected NedCoordinate" unless ned.is_a?(NedCoordinate)
    
    ned.to_enu
  end

  # Convert to LLA coordinates relative to a reference point
  def to_lla(reference_lla)
    require_relative 'lla_coordinate'
    raise ArgumentError, "Expected LlaCoordinate" unless reference_lla.is_a?(LlaCoordinate)
    
    # Convert to ECEF first, then to LLA
    reference_ecef = reference_lla.to_ecef
    ecef = self.to_ecef(reference_ecef, reference_lla)
    ecef.to_lla
  end

  # Create from LLA coordinates relative to a reference point
  def self.from_lla(lla, reference_lla)
    require_relative 'lla_coordinate'
    raise ArgumentError, "Expected LlaCoordinate" unless lla.is_a?(LlaCoordinate)
    raise ArgumentError, "Expected LlaCoordinate" unless reference_lla.is_a?(LlaCoordinate)
    
    lla.to_enu(reference_lla)
  end

  # Convert to UTM coordinates relative to a reference point
  def to_utm(reference_lla, datum = WGS84)
    require_relative 'utm_coordinate'
    require_relative 'lla_coordinate'
    raise ArgumentError, "Expected LlaCoordinate" unless reference_lla.is_a?(LlaCoordinate)
    
    # Convert to LLA first, then to UTM
    lla = self.to_lla(reference_lla)
    lla.to_utm(datum)
  end

  # Create from UTM coordinates relative to a reference point
  def self.from_utm(utm, reference_lla, datum = WGS84)
    require_relative 'utm_coordinate'
    require_relative 'lla_coordinate'
    raise ArgumentError, "Expected UtmCoordinate" unless utm.is_a?(UtmCoordinate)
    raise ArgumentError, "Expected LlaCoordinate" unless reference_lla.is_a?(LlaCoordinate)
    
    # Convert UTM to LLA first, then to ENU
    lla = utm.to_lla(datum)
    lla.to_enu(reference_lla)
  end

  # Utility methods
  def to_s
    "#{@e}, #{@n}, #{@u}"
  end

  def to_a
    [@e, @n, @u]
  end

  def ==(other)
    return false unless other.is_a?(EnuCoordinate)
    
    delta_e = (@e - other.e).abs
    delta_n = (@n - other.n).abs
    delta_u = (@u - other.u).abs
    
    delta_e <= 1e-6 && delta_n <= 1e-6 && delta_u <= 1e-6
  end

  # Calculate distance to another ENU point
  def distance_to(other)
    raise ArgumentError, "Expected EnuCoordinate" unless other.is_a?(EnuCoordinate)
    
    de = @e - other.e
    dn = @n - other.n
    du = @u - other.u
    
    Math.sqrt(de**2 + dn**2 + du**2)
  end

  # Calculate horizontal distance (ignoring up component)
  def horizontal_distance_to(other)
    raise ArgumentError, "Expected EnuCoordinate" unless other.is_a?(EnuCoordinate)
    
    de = @e - other.e
    dn = @n - other.n
    
    Math.sqrt(de**2 + dn**2)
  end

  # Calculate bearing to another ENU point (in degrees)
  def bearing_to(other)
    raise ArgumentError, "Expected EnuCoordinate" unless other.is_a?(EnuCoordinate)
    
    de = other.e - @e
    dn = other.n - @n
    
    bearing_rad = Math.atan2(de, dn)
    bearing_deg = bearing_rad * DEG_PER_RAD
    
    # Normalize to 0-360 degrees
    bearing_deg += 360 if bearing_deg < 0
    bearing_deg
  end
  
  # Calculate distance from origin
  def distance_to_origin
    Math.sqrt(@e**2 + @n**2 + @u**2)
  end
  
  # Calculate bearing from origin
  def bearing_from_origin
    bearing_rad = Math.atan2(@e, @n)
    bearing_deg = bearing_rad * DEG_PER_RAD
    
    # Normalize to 0-360 degrees
    bearing_deg += 360 if bearing_deg < 0
    bearing_deg
  end
  
  # Calculate horizontal distance from origin
  def horizontal_distance_to_origin
    Math.sqrt(@e**2 + @n**2)
  end
end