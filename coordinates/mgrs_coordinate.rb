# Military Grid Reference System (MGRS) Coordinate
# Converts between MGRS grid references and other coordinate systems
# MGRS is based on UTM but uses a more compact alphanumeric format

class MgrsCoordinate
  require_relative 'geo_datum'
  
  attr_accessor :grid_zone_designator, :square_identifier, :easting, :northing, :precision
  
  # MGRS 100km square identification letters
  SET1_E = 'ABCDEFGHJKLMNPQRSTUVWXYZ'  # Columns (exclude I and O)
  SET2_E = 'ABCDEFGHJKLMNPQRSTUVWXYZ'  # Columns for odd UTM zones
  SET1_N = 'ABCDEFGHJKLMNPQRSTUV'      # Rows (exclude I and O, stop at V)
  SET2_N = 'FGHJKLMNPQRSTUVABCDE'      # Rows for even-numbered 100km squares
  
  def initialize(mgrs_string = nil, grid_zone = nil, square_id = nil, east = nil, north = nil, precision = 5)
    if mgrs_string
      parse_mgrs_string(mgrs_string)
    else
      @grid_zone_designator = grid_zone
      @square_identifier = square_id
      @easting = east.to_f
      @northing = north.to_f
      @precision = precision
    end
  end
  
  def to_s
    if @precision == 1
      "#{@grid_zone_designator}#{@square_identifier}"
    else
      east_str = ("%0#{@precision}d" % (@easting / (10 ** (5 - @precision)))).to_s
      north_str = ("%0#{@precision}d" % (@northing / (10 ** (5 - @precision)))).to_s
      "#{@grid_zone_designator}#{@square_identifier}#{east_str}#{north_str}"
    end
  end
  
  def to_utm
    require_relative 'utm_coordinate'
    
    # Extract zone number and hemisphere from grid zone designator
    zone_number = @grid_zone_designator[0..-2].to_i
    zone_letter = @grid_zone_designator[-1]
    hemisphere = (zone_letter >= 'N') ? 'N' : 'S'
    
    # Convert 100km square to UTM coordinates
    utm_easting, utm_northing = square_to_utm(zone_number, @square_identifier, @easting, @northing)
    
    UtmCoordinate.new(utm_easting, utm_northing, zone_number, hemisphere)
  end
  
  def self.from_utm(utm_coord, precision = 5)
    # Create instance to access instance methods
    temp_instance = new
    
    # Get 100km square identifier
    square_id = temp_instance.utm_to_square(utm_coord.zone, utm_coord.easting, utm_coord.northing)
    
    # Calculate position within the 100km square
    square_easting = utm_coord.easting % 100000
    square_northing = utm_coord.northing % 100000
    
    # Create grid zone designator
    zone_letter = utm_coord.hemisphere == 'N' ? get_zone_letter(utm_coord.northing) : get_zone_letter_south(utm_coord.northing)
    grid_zone = "#{utm_coord.zone}#{zone_letter}"
    
    new(nil, grid_zone, square_id, square_easting, square_northing, precision)
  end
  
  def to_lla(datum = WGS84)
    utm_coord = to_utm
    utm_coord.to_lla(datum)
  end
  
  def self.from_lla(lla_coord, datum = WGS84, precision = 5)
    require_relative 'utm_coordinate'
    utm_coord = UtmCoordinate.from_lla(lla_coord, datum)
    from_utm(utm_coord, precision)
  end
  
  def to_ecef(datum = WGS84)
    to_lla(datum).to_ecef(datum)
  end
  
  def self.from_ecef(ecef_coord, datum = WGS84, precision = 5)
    lla_coord = ecef_coord.to_lla(datum)
    from_lla(lla_coord, datum, precision)
  end
  
  def to_enu(reference_lla, datum = WGS84)
    to_lla(datum).to_enu(reference_lla, datum)
  end
  
  def self.from_enu(enu_coord, reference_lla, datum = WGS84, precision = 5)
    lla_coord = enu_coord.to_lla(reference_lla, datum)
    from_lla(lla_coord, datum, precision)
  end
  
  def to_ned(reference_lla, datum = WGS84)
    to_lla(datum).to_ned(reference_lla, datum)
  end
  
  def self.from_ned(ned_coord, reference_lla, datum = WGS84, precision = 5)
    lla_coord = ned_coord.to_lla(reference_lla, datum)
    from_lla(lla_coord, datum, precision)
  end
  
  def utm_to_square(zone_number, easting, northing)
    # Calculate 100km square column
    col_index = ((easting - 100000) / 100000).floor
    col_index = (col_index + (zone_number - 1) * 8) % 24
    
    if zone_number % 2 == 1  # Odd zones
      col_letter = SET1_E[col_index]
    else  # Even zones
      col_letter = SET2_E[col_index]
    end
    
    # Calculate 100km square row
    row_index = (northing / 100000).floor % 20
    if ((zone_number - 1) / 6).floor % 2 == 1
      row_letter = SET2_N[row_index]
    else
      row_letter = SET1_N[row_index]
    end
    
    "#{col_letter}#{row_letter}"
  end
  
  private
  
  def parse_mgrs_string(mgrs_string)
    mgrs = mgrs_string.upcase.gsub(/\s/, '')
    
    # Extract grid zone designator (first 2-3 characters: zone number + letter)
    if mgrs.match(/^(\d{1,2}[A-Z])/)
      @grid_zone_designator = $1
      remainder = mgrs[($1.length)..-1]
    else
      raise "Invalid MGRS format: #{mgrs_string}"
    end
    
    # Extract 100km square identifier (next 2 characters)
    if remainder.length >= 2
      @square_identifier = remainder[0..1]
      coords = remainder[2..-1]
    else
      raise "Invalid MGRS format: missing square identifier"
    end
    
    # Extract coordinates (remaining characters, split evenly)
    if coords.length == 0
      @precision = 1  # Grid square only
      @easting = 0.0
      @northing = 0.0
    elsif coords.length % 2 == 0
      @precision = coords.length / 2
      coord_multiplier = 10 ** (5 - @precision)
      @easting = coords[0...@precision].to_i * coord_multiplier
      @northing = coords[@precision..-1].to_i * coord_multiplier
    else
      raise "Invalid MGRS format: uneven coordinate length"
    end
  end
  
  def square_to_utm(zone_number, square_id, easting, northing)
    col_letter = square_id[0]
    row_letter = square_id[1]
    
    # Calculate 100km square origin
    col_origin = (SET1_E.index(col_letter) || 0) * 100000
    if zone_number % 2 == 0  # Even zones use SET2
      col_origin = (SET2_E.index(col_letter) || 0) * 100000
    end
    
    # Adjust for zone offset
    col_origin += ((zone_number - 1) % 3) * 800000
    col_origin = col_origin % 800000 + 100000
    
    # Row calculation is more complex due to latitude bands
    row_origin = get_row_origin(zone_number, row_letter)
    
    utm_easting = col_origin + easting
    utm_northing = row_origin + northing
    
    [utm_easting, utm_northing]
  end
  
  def get_row_origin(zone_number, row_letter)
    # Simplified row origin calculation
    # In reality, this depends on the specific latitude band
    row_index = SET1_N.index(row_letter) || SET2_N.index(row_letter) || 0
    if ((zone_number - 1) / 6).floor % 2 == 1
      row_index = SET2_N.index(row_letter) || 0
    else
      row_index = SET1_N.index(row_letter) || 0
    end
    
    row_index * 100000
  end
  
  def self.get_zone_letter(northing)
    # UTM zone letters based on northing
    letters = 'CDEFGHJKLMNPQRSTUVWX'
    band = ((northing + 10000000) / 800000).floor
    band = [0, [band, letters.length - 1].min].max
    letters[band]
  end
  
  def self.get_zone_letter_south(northing)
    # Southern hemisphere zone letters
    letters = 'ABCDEFGHJKLM'
    band = ((10000000 - northing) / 800000).floor
    band = [0, [band, letters.length - 1].min].max
    letters[band]
  end
end