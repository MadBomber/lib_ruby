#############################
## Universal Transverse Mercator
##
## Updated: Complete orthogonal coordinate conversions

require_relative 'geo_datum'

class UtmCoordinate
  attr_accessor :easting, :northing, :altitude, :zone, :hemisphere
  alias_method :x, :easting
  alias_method :y, :northing
  alias_method :z, :altitude

  def initialize(easting = 0.0, northing = 0.0, altitude = 0.0, zone = 1, hemisphere = 'N')
    if easting.is_a?(Array)
      @easting = easting[0].to_f
      @northing = easting[1].to_f
      @altitude = easting[2].to_f
      @zone = easting[3] || zone
      @hemisphere = easting[4] || hemisphere
    else
      @easting = easting.to_f
      @northing = northing.to_f
      @altitude = altitude.to_f
      @zone = zone.to_i
      @hemisphere = hemisphere.to_s.upcase
    end
    
    validate_parameters!
  end

  # Convert to LLA coordinates
  def to_lla(datum = WGS84)
    require_relative 'lla_coordinate'
    
    # UTM parameters
    k0 = 0.9996  # Scale factor
    false_easting = 500000.0
    false_northing = @hemisphere == 'S' ? 10000000.0 : 0.0
    
    # Remove false easting and northing
    x = @easting - false_easting
    y = @northing - false_northing
    
    # Central meridian for the zone
    lon0_deg = (@zone - 1) * 6 - 180 + 3
    lon0_rad = lon0_deg * RAD_PER_DEG
    
    # Datum parameters
    a = datum.a
    e2 = datum.e2
    e4 = e2 * e2
    e6 = e4 * e2
    
    # Footprint latitude calculation (simplified)
    m = y / k0
    mu = m / (a * (1 - e2/4 - 3*e4/64 - 5*e6/256))
    
    # Calculate latitude using series expansion
    lat_rad = mu + 
              (3*datum.e/2 - 27*datum.e**3/32) * Math.sin(2*mu) +
              (21*datum.e**2/16 - 55*datum.e**4/32) * Math.sin(4*mu) +
              (151*datum.e**3/96) * Math.sin(6*mu)
    
    # Calculate longitude (simplified)
    cos_lat = Math.cos(lat_rad)
    sin_lat = Math.sin(lat_rad)
    tan_lat = Math.tan(lat_rad)
    
    n = a / Math.sqrt(1 - e2 * sin_lat**2)
    t = tan_lat**2
    c = e2 * cos_lat**2 / (1 - e2)
    r = a * (1 - e2) / (1 - e2 * sin_lat**2)**(3/2.0)
    d = x / (n * k0)
    
    lon_rad = lon0_rad + (d - (1 + 2*t + c)*d**3/6 + 
                         (5 - 2*c + 28*t - 3*c**2 + 8*datum.e2 + 24*t**2)*d**5/120) / cos_lat
    
    # Refine latitude
    lat_rad = lat_rad - (n * tan_lat / r) * 
              (d**2/2 - (5 + 3*t + 10*c - 4*c**2 - 9*datum.e2)*d**4/24 +
               (61 + 90*t + 298*c + 45*t**2 - 252*datum.e2 - 3*c**2)*d**6/720)
    
    # Apply hemisphere correction
    lat_rad = -lat_rad if @hemisphere == 'S'
    
    lat_deg = lat_rad * DEG_PER_RAD
    lon_deg = lon_rad * DEG_PER_RAD
    
    # Normalize longitude to [-180, 180]
    lon_deg += 360 while lon_deg < -180
    lon_deg -= 360 while lon_deg > 180
    
    LlaCoordinate.new(lat_deg, lon_deg, @altitude)
  end

  # Create from LLA coordinates
  def self.from_lla(lla, datum = WGS84)
    require_relative 'lla_coordinate'
    raise ArgumentError, "Expected LlaCoordinate" unless lla.is_a?(LlaCoordinate)
    
    lla.to_utm(datum)
  end

  # Convert to ECEF coordinates
  def to_ecef(datum = WGS84)
    require_relative 'ecef_coordinate'
    
    # Convert through LLA
    lla = self.to_lla(datum)
    lla.to_ecef(datum)
  end

  # Create from ECEF coordinates
  def self.from_ecef(ecef, datum = WGS84)
    require_relative 'ecef_coordinate'
    raise ArgumentError, "Expected EcefCoordinate" unless ecef.is_a?(EcefCoordinate)
    
    ecef.to_utm(datum)
  end

  # Convert to ENU coordinates relative to a reference point
  def to_enu(reference_lla, datum = WGS84)
    require_relative 'enu_coordinate'
    require_relative 'lla_coordinate'
    raise ArgumentError, "Expected LlaCoordinate" unless reference_lla.is_a?(LlaCoordinate)
    
    # Convert to LLA first, then to ENU
    lla = self.to_lla(datum)
    lla.to_enu(reference_lla)
  end

  # Create from ENU coordinates relative to a reference point
  def self.from_enu(enu, reference_lla, datum = WGS84)
    require_relative 'enu_coordinate'
    require_relative 'lla_coordinate'
    raise ArgumentError, "Expected EnuCoordinate" unless enu.is_a?(EnuCoordinate)
    raise ArgumentError, "Expected LlaCoordinate" unless reference_lla.is_a?(LlaCoordinate)
    
    enu.to_utm(reference_lla, datum)
  end

  # Convert to NED coordinates relative to a reference point
  def to_ned(reference_lla, datum = WGS84)
    require_relative 'ned_coordinate'
    require_relative 'lla_coordinate'
    raise ArgumentError, "Expected LlaCoordinate" unless reference_lla.is_a?(LlaCoordinate)
    
    # Convert to LLA first, then to NED
    lla = self.to_lla(datum)
    lla.to_ned(reference_lla)
  end

  # Create from NED coordinates relative to a reference point
  def self.from_ned(ned, reference_lla, datum = WGS84)
    require_relative 'ned_coordinate'
    require_relative 'lla_coordinate'
    raise ArgumentError, "Expected NedCoordinate" unless ned.is_a?(NedCoordinate)
    raise ArgumentError, "Expected LlaCoordinate" unless reference_lla.is_a?(LlaCoordinate)
    
    ned.to_utm(reference_lla, datum)
  end

  # Utility methods
  def to_s
    "#{@easting}, #{@northing}, #{@altitude} (Zone #{@zone}#{@hemisphere})"
  end

  def to_a
    [@easting, @northing, @altitude, @zone, @hemisphere]
  end

  def ==(other)
    return false unless other.is_a?(UtmCoordinate)
    
    delta_easting = (@easting - other.easting).abs
    delta_northing = (@northing - other.northing).abs
    delta_altitude = (@altitude - other.altitude).abs
    
    delta_easting <= 1e-6 && delta_northing <= 1e-6 && delta_altitude <= 1e-6 &&
    @zone == other.zone && @hemisphere == other.hemisphere
  end

  # Calculate distance to another UTM point (same zone only)
  def distance_to(other)
    raise ArgumentError, "Expected UtmCoordinate" unless other.is_a?(UtmCoordinate)
    raise ArgumentError, "UTM zones must match for distance calculation" unless same_zone?(other)
    
    de = @easting - other.easting
    dn = @northing - other.northing
    da = @altitude - other.altitude
    
    Math.sqrt(de**2 + dn**2 + da**2)
  end

  # Calculate horizontal distance (ignoring altitude)
  def horizontal_distance_to(other)
    raise ArgumentError, "Expected UtmCoordinate" unless other.is_a?(UtmCoordinate)
    raise ArgumentError, "UTM zones must match for distance calculation" unless same_zone?(other)
    
    de = @easting - other.easting
    dn = @northing - other.northing
    
    Math.sqrt(de**2 + dn**2)
  end

  # Check if two UTM coordinates are in the same zone
  def same_zone?(other)
    raise ArgumentError, "Expected UtmCoordinate" unless other.is_a?(UtmCoordinate)
    
    @zone == other.zone && @hemisphere == other.hemisphere
  end

  # Get the central meridian for this UTM zone
  def central_meridian
    (@zone - 1) * 6 - 180 + 3
  end

  private

  def validate_parameters!
    raise ArgumentError, "UTM zone must be between 1 and 60" if @zone < 1 || @zone > 60
    raise ArgumentError, "Hemisphere must be 'N' or 'S'" unless ['N', 'S'].include?(@hemisphere)
    raise ArgumentError, "Easting must be positive" if @easting < 0
    raise ArgumentError, "Northing must be positive" if @northing < 0
  end
end