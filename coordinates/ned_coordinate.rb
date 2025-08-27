####################
## North, East, Down
##
## Updated: Complete orthogonal coordinate conversions

require_relative 'geo_datum'

class NedCoordinate
  attr_accessor :n, :e, :d
  alias_method :north, :n
  alias_method :east, :e
  alias_method :down, :d

  def initialize(n = 0.0, e = 0.0, d = 0.0)
    if n.is_a?(Array)
      @n = n[0].to_f
      @e = n[1].to_f
      @d = n[2].to_f
    else
      @n = n.to_f
      @e = e.to_f
      @d = d.to_f
    end
  end

  # Convert to ENU coordinates (simple coordinate swap)
  def to_enu
    require_relative 'enu_coordinate'
    
    # NED to ENU: N->N, E->E, D->-U
    EnuCoordinate.new(@e, @n, -@d)
  end

  # Create from ENU coordinates
  def self.from_enu(enu)
    require_relative 'enu_coordinate'
    raise ArgumentError, "Expected EnuCoordinate" unless enu.is_a?(EnuCoordinate)
    
    enu.to_ned
  end

  # Convert to ECEF coordinates relative to a reference point
  def to_ecef(reference_ecef, reference_lla = nil)
    require_relative 'ecef_coordinate'
    raise ArgumentError, "Expected EcefCoordinate" unless reference_ecef.is_a?(EcefCoordinate)
    
    # Convert to ENU first, then to ECEF
    enu = self.to_enu
    enu.to_ecef(reference_ecef, reference_lla)
  end

  # Create from ECEF coordinates relative to a reference point
  def self.from_ecef(ecef, reference_ecef, reference_lla = nil)
    require_relative 'ecef_coordinate'
    raise ArgumentError, "Expected EcefCoordinate" unless ecef.is_a?(EcefCoordinate)
    raise ArgumentError, "Expected EcefCoordinate" unless reference_ecef.is_a?(EcefCoordinate)
    
    # Convert to ENU first, then to NED
    enu = ecef.to_enu(reference_ecef, reference_lla)
    enu.to_ned
  end

  # Convert to LLA coordinates relative to a reference point
  def to_lla(reference_lla)
    require_relative 'lla_coordinate'
    raise ArgumentError, "Expected LlaCoordinate" unless reference_lla.is_a?(LlaCoordinate)
    
    # Convert to ENU first, then to LLA
    enu = self.to_enu
    enu.to_lla(reference_lla)
  end

  # Create from LLA coordinates relative to a reference point
  def self.from_lla(lla, reference_lla)
    require_relative 'lla_coordinate'
    raise ArgumentError, "Expected LlaCoordinate" unless lla.is_a?(LlaCoordinate)
    raise ArgumentError, "Expected LlaCoordinate" unless reference_lla.is_a?(LlaCoordinate)
    
    lla.to_ned(reference_lla)
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
    
    # Convert UTM to LLA first, then to NED
    lla = utm.to_lla(datum)
    lla.to_ned(reference_lla)
  end

  # Utility methods
  def to_s
    "#{@n}, #{@e}, #{@d}"
  end

  def to_a
    [@n, @e, @d]
  end

  def ==(other)
    return false unless other.is_a?(NedCoordinate)
    
    delta_n = (@n - other.n).abs
    delta_e = (@e - other.e).abs
    delta_d = (@d - other.d).abs
    
    delta_n <= 1e-6 && delta_e <= 1e-6 && delta_d <= 1e-6
  end

  # Calculate distance to another NED point
  def distance_to(other)
    raise ArgumentError, "Expected NedCoordinate" unless other.is_a?(NedCoordinate)
    
    dn = @n - other.n
    de = @e - other.e
    dd = @d - other.d
    
    Math.sqrt(dn**2 + de**2 + dd**2)
  end

  # Calculate horizontal distance (ignoring down component)
  def horizontal_distance_to(other)
    raise ArgumentError, "Expected NedCoordinate" unless other.is_a?(NedCoordinate)
    
    dn = @n - other.n
    de = @e - other.e
    
    Math.sqrt(dn**2 + de**2)
  end

  # Calculate bearing to another NED point (in degrees)
  def bearing_to(other)
    raise ArgumentError, "Expected NedCoordinate" unless other.is_a?(NedCoordinate)
    
    dn = other.n - @n
    de = other.e - @e
    
    bearing_rad = Math.atan2(de, dn)
    bearing_deg = bearing_rad * DEG_PER_RAD
    
    # Normalize to 0-360 degrees
    bearing_deg += 360 if bearing_deg < 0
    bearing_deg
  end

  # Calculate elevation angle to another NED point (in degrees)
  def elevation_angle_to(other)
    raise ArgumentError, "Expected NedCoordinate" unless other.is_a?(NedCoordinate)
    
    horizontal_dist = horizontal_distance_to(other)
    return 0.0 if horizontal_dist == 0.0
    
    vertical_diff = @d - other.d  # Positive if other is above this point
    elevation_rad = Math.atan2(vertical_diff, horizontal_dist)
    elevation_rad * DEG_PER_RAD
  end
  
  # Calculate distance from origin
  def distance_to_origin
    Math.sqrt(@n**2 + @e**2 + @d**2)
  end
  
  # Calculate elevation angle from origin
  def elevation_angle
    horizontal_dist = Math.sqrt(@n**2 + @e**2)
    return 0.0 if horizontal_dist == 0.0
    
    # Elevation angle (positive if above origin)
    elevation_rad = Math.atan2(-@d, horizontal_dist)  # Negative d means above
    elevation_rad * DEG_PER_RAD
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
    Math.sqrt(@n**2 + @e**2)
  end
end