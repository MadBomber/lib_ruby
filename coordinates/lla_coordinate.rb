################################
## Latitude, Longitude, Altitude
##
## A negative longitude is the Western hemisphere.
## A negative latitude is in the Southern hemisphere.
## Altitude is in decimal meters
##
## Updated: Complete orthogonal coordinate conversions

require_relative 'geo_datum'
require_relative 'geoid_height'

class LlaCoordinate
  include GeoidHeightSupport
  attr_accessor :lat, :lng, :alt
  alias_method :latitude, :lat
  alias_method :longitude, :lng
  alias_method :altitude, :alt

  def initialize(latitude_deg = 0.0, longitude_deg = 0.0, altitude_meters = 0.0)
    if latitude_deg.is_a?(Array)
      @lat = latitude_deg[0].to_f
      @lng = latitude_deg[1].to_f
      @alt = latitude_deg[2].to_f
    else
      @lat = latitude_deg.to_f
      @lng = longitude_deg.to_f
      @alt = altitude_meters.to_f
    end
    
    validate_coordinates!
  end

  # Convert to ECEF (Earth-Centered, Earth-Fixed) coordinates
  def to_ecef(datum = WGS84)
    require_relative 'ecef_coordinate'
    
    latitude_rad  = @lat * RAD_PER_DEG
    longitude_rad = @lng * RAD_PER_DEG

    a  = datum.a        # Semi-major axis (equatorial) radius in meters
    e2 = datum.e2       # Eccentricity squared

    n = a / Math.sqrt(1 - e2 * (Math.sin(latitude_rad))**2)

    cos_lat = Math.cos(latitude_rad)
    sin_lat = Math.sin(latitude_rad)
    cos_lon = Math.cos(longitude_rad)
    sin_lon = Math.sin(longitude_rad)

    x = (n + @alt) * cos_lat * cos_lon
    y = (n + @alt) * cos_lat * sin_lon
    z = (n * (1 - e2) + @alt) * sin_lat

    EcefCoordinate.new(x, y, z)
  end

  # Create from ECEF coordinates
  def self.from_ecef(ecef, datum = WGS84)
    require_relative 'ecef_coordinate'
    raise ArgumentError, "Expected EcefCoordinate" unless ecef.is_a?(EcefCoordinate)
    
    ecef.to_lla(datum)
  end

  # Convert to UTM coordinates
  def to_utm(datum = WGS84)
    require_relative 'utm_coordinate'
    
    # Convert through the conversion algorithms
    lat_rad = @lat * RAD_PER_DEG
    lon_rad = @lng * RAD_PER_DEG
    
    # Determine UTM zone
    zone = (((@lng + 180) / 6).floor + 1).to_i
    zone = 60 if zone > 60
    zone = 1 if zone < 1
    
    # UTM conversion (simplified algorithm)
    a = datum.a
    e2 = datum.e2
    
    # Central meridian for the zone
    lon0_deg = (zone - 1) * 6 - 180 + 3
    lon0_rad = lon0_deg * RAD_PER_DEG
    
    # UTM constants
    k0 = 0.9996  # Scale factor
    
    # Calculate UTM coordinates (simplified)
    n = a / Math.sqrt(1 - e2 * Math.sin(lat_rad)**2)
    t = Math.tan(lat_rad)
    c = e2 * Math.cos(lat_rad)**2 / (1 - e2)
    aa = Math.cos(lat_rad) * (lon_rad - lon0_rad)
    
    # Simplified UTM formulas
    x = k0 * n * (aa + (1 - t**2 + c) * aa**3 / 6)
    y = k0 * (lat_rad + aa**2 * t / 2)
    
    # Apply false easting and northing
    x += 500000  # False easting
    y += 10000000 if @lat < 0  # False northing for southern hemisphere
    
    hemisphere = @lat >= 0 ? 'N' : 'S'
    
    UtmCoordinate.new(x, y, @alt, zone, hemisphere)
  end

  # Create from UTM coordinates
  def self.from_utm(utm, datum = WGS84)
    require_relative 'utm_coordinate'
    raise ArgumentError, "Expected UtmCoordinate" unless utm.is_a?(UtmCoordinate)
    
    utm.to_lla(datum)
  end

  # Convert to NED coordinates relative to a reference point
  def to_ned(reference_lla)
    require_relative 'ned_coordinate'
    raise ArgumentError, "Expected LlaCoordinate" unless reference_lla.is_a?(LlaCoordinate)
    
    # Convert both points to ECEF first
    ecef = self.to_ecef
    ref_ecef = reference_lla.to_ecef
    
    # Convert ECEF difference to NED
    ecef.to_ned(ref_ecef, reference_lla)
  end

  # Create from NED coordinates relative to a reference point
  def self.from_ned(ned, reference_lla)
    require_relative 'ned_coordinate'
    raise ArgumentError, "Expected NedCoordinate" unless ned.is_a?(NedCoordinate)
    raise ArgumentError, "Expected LlaCoordinate" unless reference_lla.is_a?(LlaCoordinate)
    
    ned.to_lla(reference_lla)
  end

  # Convert to ENU coordinates relative to a reference point
  def to_enu(reference_lla)
    require_relative 'enu_coordinate'
    raise ArgumentError, "Expected LlaCoordinate" unless reference_lla.is_a?(LlaCoordinate)
    
    # Convert both points to ECEF first
    ecef = self.to_ecef
    ref_ecef = reference_lla.to_ecef
    
    # Convert ECEF difference to ENU
    ecef.to_enu(ref_ecef, reference_lla)
  end

  # Create from ENU coordinates relative to a reference point
  def self.from_enu(enu, reference_lla)
    require_relative 'enu_coordinate'
    raise ArgumentError, "Expected EnuCoordinate" unless enu.is_a?(EnuCoordinate)
    raise ArgumentError, "Expected LlaCoordinate" unless reference_lla.is_a?(LlaCoordinate)
    
    enu.to_lla(reference_lla)
  end

  # DMS (degrees, minutes, seconds) conversion methods
  # Return a DMS (degrees, minutes, seconds) string representation
  def to_dms
    # Latitude
    lat_abs = @lat.abs
    lat_deg = lat_abs.floor
    lat_min_total = (lat_abs - lat_deg) * 60.0
    lat_min = lat_min_total.floor
    lat_sec = (lat_min_total - lat_min) * 60.0
    lat_hemi = @lat >= 0 ? 'N' : 'S'

    # Longitude
    lon_abs = @lng.abs
    lon_deg = lon_abs.floor
    lon_min_total = (lon_abs - lon_deg) * 60.0
    lon_min = lon_min_total.floor
    lon_sec = (lon_min_total - lon_min) * 60.0
    lon_hemi = @lng >= 0 ? 'E' : 'W'

    # Format strings with two decimal places for seconds and altitude
    lat_str = format("%d° %d' %.2f\" %s", lat_deg, lat_min, lat_sec, lat_hemi)
    lon_str = format("%d° %d' %.2f\" %s", lon_deg, lon_min, lon_sec, lon_hemi)
    alt_str = format("%.2f m", @alt)

    "#{lat_str}, #{lon_str}, #{alt_str}"
  end

  # Create a LlaCoordinate from a DMS-formatted string
  def self.from_dms(dms_str)
    # Expect formats like "37° 46' 29.64\" N, 122° 25' 09.24\" W, 15.30 m"
    regex = /^\s*([0-9]+)°\s*([0-9]+)'\s*([0-9]+(?:\.[0-9]+)?)"\s*([NS])\s*,\s*([0-9]+)°\s*([0-9]+)'\s*([0-9]+(?:\.[0-9]+)?)"\s*([EW])\s*(?:,\s*([\-+]?[0-9]+(?:\.[0-9]+)?)\s*m?)?\s*$/i
    m = dms_str.match(regex)
    raise ArgumentError, "Invalid DMS format" unless m

    lat_deg = m[1].to_i
    lat_min = m[2].to_i
    lat_sec = m[3].to_f
    lat_hemi = m[4].upcase

    lon_deg = m[5].to_i
    lon_min = m[6].to_i
    lon_sec = m[7].to_f
    lon_hemi = m[8].upcase

    alt = m[9] ? m[9].to_f : 0.0

    # Compute decimal degrees
    lat = lat_deg + lat_min / 60.0 + lat_sec / 3600.0
    lat = -lat if lat_hemi == 'S'

    lng = lon_deg + lon_min / 60.0 + lon_sec / 3600.0
    lng = -lng if lon_hemi == 'W'

    new(lat, lng, alt)
  end
  def to_s
    "#{@lat}, #{@lng}, #{@alt}"
  end

  def to_a
    [@lat, @lng, @alt]
  end

  def ==(other)
    return false unless other.is_a?(LlaCoordinate)
    
    delta_lat = (@lat - other.lat).abs
    delta_lng = (@lng - other.lng).abs
    delta_alt = (@alt - other.alt).abs
    
    delta_lat <= 1e-10 && delta_lng <= 1e-10 && delta_alt <= 1e-6
  end

  private

  def validate_coordinates!
    raise ArgumentError, "Latitude must be between -90 and 90 degrees" if @lat < -90 || @lat > 90
    raise ArgumentError, "Longitude must be between -180 and 180 degrees" if @lng < -180 || @lng > 180
  end
end