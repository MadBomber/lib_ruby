# Geoid Height and Vertical Datum Support
# Provides conversion between ellipsoidal heights and orthometric heights
# Supports multiple geoid models and vertical datums

class GeoidHeight
  require_relative 'geo_datum'
  
  attr_accessor :geoid_model, :interpolation_method
  
  # Geoid model constants (simplified - real implementation would load actual geoid data)
  GEOID_MODELS = {
    'EGM96' => {
      name: 'Earth Gravitational Model 1996',
      resolution: 15.0,  # arc minutes
      accuracy: 1.0,     # meters RMS
      epoch: 1996
    },
    'EGM2008' => {
      name: 'Earth Gravitational Model 2008',
      resolution: 2.5,   # arc minutes
      accuracy: 0.5,     # meters RMS
      epoch: 2008
    },
    'GEOID18' => {
      name: 'GEOID18 (CONUS)',
      resolution: 1.0,   # arc minutes
      accuracy: 0.1,     # meters RMS (in CONUS)
      region: 'CONUS',
      epoch: 2018
    },
    'GEOID12B' => {
      name: 'GEOID12B (CONUS)',
      resolution: 1.0,   # arc minutes
      accuracy: 0.15,    # meters RMS
      region: 'CONUS',
      epoch: 2012
    }
  }
  
  # Vertical datums
  VERTICAL_DATUMS = {
    'NAVD88' => {
      name: 'North American Vertical Datum of 1988',
      region: 'North America',
      type: 'orthometric',
      reference_geoid: 'GEOID18'
    },
    'NGVD29' => {
      name: 'National Geodetic Vertical Datum of 1929',
      region: 'United States',
      type: 'orthometric',
      reference_geoid: 'GEOID12B'
    },
    'MSL' => {
      name: 'Mean Sea Level',
      region: 'Global',
      type: 'orthometric',
      reference_geoid: 'EGM2008'
    },
    'HAE' => {
      name: 'Height Above Ellipsoid',
      region: 'Global',
      type: 'ellipsoidal',
      reference_geoid: nil
    }
  }
  
  def initialize(geoid_model = 'EGM2008', interpolation_method = 'bilinear')
    @geoid_model = geoid_model
    @interpolation_method = interpolation_method
    validate_model
  end
  
  # Get geoid height at a given lat/lng position
  def geoid_height_at(lat, lng)
    case @geoid_model
    when 'EGM96'
      calculate_egm96_height(lat, lng)
    when 'EGM2008'
      calculate_egm2008_height(lat, lng)
    when 'GEOID18'
      calculate_geoid18_height(lat, lng)
    when 'GEOID12B'
      calculate_geoid12b_height(lat, lng)
    else
      raise "Unsupported geoid model: #{@geoid_model}"
    end
  end
  
  # Convert ellipsoidal height to orthometric height
  def ellipsoidal_to_orthometric(lat, lng, ellipsoidal_height)
    geoid_height = geoid_height_at(lat, lng)
    orthometric_height = ellipsoidal_height - geoid_height
    orthometric_height
  end
  
  # Convert orthometric height to ellipsoidal height
  def orthometric_to_ellipsoidal(lat, lng, orthometric_height)
    geoid_height = geoid_height_at(lat, lng)
    ellipsoidal_height = orthometric_height + geoid_height
    ellipsoidal_height
  end
  
  # Convert between vertical datums
  def convert_vertical_datum(lat, lng, height, from_datum, to_datum)
    from_info = VERTICAL_DATUMS[from_datum]
    to_info = VERTICAL_DATUMS[to_datum]
    
    raise "Unknown vertical datum: #{from_datum}" unless from_info
    raise "Unknown vertical datum: #{to_datum}" unless to_info
    
    # Convert to common reference (ellipsoidal height)
    if from_info[:type] == 'orthometric'
      # Convert from orthometric to ellipsoidal
      geoid_model = GeoidHeight.new(from_info[:reference_geoid])
      ellipsoidal_height = geoid_model.orthometric_to_ellipsoidal(lat, lng, height)
    else
      # Already ellipsoidal
      ellipsoidal_height = height
    end
    
    # Convert from ellipsoidal to target datum
    if to_info[:type] == 'orthometric'
      # Convert from ellipsoidal to orthometric
      geoid_model = GeoidHeight.new(to_info[:reference_geoid])
      target_height = geoid_model.ellipsoidal_to_orthometric(lat, lng, ellipsoidal_height)
    else
      # Target is ellipsoidal
      target_height = ellipsoidal_height
    end
    
    target_height
  end
  
  # Get interpolated geoid height using bilinear interpolation
  def interpolated_height(lat, lng, height_grid, lat_grid, lng_grid)
    # Find grid cell containing the point
    lat_idx = find_grid_index(lat, lat_grid)
    lng_idx = find_grid_index(lng, lng_grid)
    
    # Get corner points
    lat1, lat2 = lat_grid[lat_idx], lat_grid[lat_idx + 1]
    lng1, lng2 = lng_grid[lng_idx], lng_grid[lng_idx + 1]
    
    # Get heights at corners
    h11 = height_grid[lat_idx][lng_idx]
    h12 = height_grid[lat_idx][lng_idx + 1]
    h21 = height_grid[lat_idx + 1][lng_idx]
    h22 = height_grid[lat_idx + 1][lng_idx + 1]
    
    # Bilinear interpolation
    t = (lng - lng1) / (lng2 - lng1)
    u = (lat - lat1) / (lat2 - lat1)
    
    height = (1 - t) * (1 - u) * h11 + 
             t * (1 - u) * h12 + 
             (1 - t) * u * h21 + 
             t * u * h22
    
    height
  end
  
  # Calculate geoid undulation correction
  def undulation_correction(lat)
    # Simplified model for demonstration
    # Real implementation would use spherical harmonics
    lat_rad = lat * Math::PI / 180.0
    correction = 10.0 * Math.sin(2.0 * lat_rad) + 5.0 * Math.sin(4.0 * lat_rad)
    correction
  end
  
  # Get accuracy estimate for geoid model at location
  def accuracy_estimate(lat, lng)
    model_info = GEOID_MODELS[@geoid_model]
    base_accuracy = model_info[:accuracy]
    
    # Accuracy may vary by region (simplified model)
    if model_info[:region] == 'CONUS'
      # Better accuracy within CONUS
      if lat >= 24.0 && lat <= 50.0 && lng >= -125.0 && lng <= -66.0
        return base_accuracy
      else
        return base_accuracy * 3.0  # Degraded outside region
      end
    end
    
    base_accuracy
  end
  
  # Check if location is within model coverage
  def in_coverage?(lat, lng)
    model_info = GEOID_MODELS[@geoid_model]
    
    case model_info[:region]
    when 'CONUS'
      lat >= 20.0 && lat <= 55.0 && lng >= -130.0 && lng <= -60.0
    when 'North America'
      lat >= 10.0 && lat <= 85.0 && lng >= -180.0 && lng <= -40.0
    else
      true  # Global coverage
    end
  end
  
  # Get all available models
  def self.available_models
    GEOID_MODELS.keys
  end
  
  # Get all available vertical datums
  def self.available_vertical_datums
    VERTICAL_DATUMS.keys
  end
  
  # Get model information
  def model_info
    GEOID_MODELS[@geoid_model]
  end
  
  private
  
  def validate_model
    unless GEOID_MODELS.key?(@geoid_model)
      raise "Unknown geoid model: #{@geoid_model}"
    end
  end
  
  def find_grid_index(value, grid)
    # Find index such that grid[index] <= value < grid[index+1]
    grid.each_with_index do |grid_val, i|
      if i == grid.length - 1 || value < grid[i + 1]
        return [i, grid.length - 2].min
      end
    end
    0
  end
  
  # Simplified geoid height calculations (placeholder implementations)
  # Real implementations would load and interpolate actual geoid grids
  
  def calculate_egm96_height(lat, lng)
    # Simplified EGM96 approximation using spherical harmonics
    lat_rad = lat * Math::PI / 180.0
    lng_rad = lng * Math::PI / 180.0
    
    # Very simplified model (real EGM96 has thousands of coefficients)
    height = 30.0 * Math.sin(2.0 * lat_rad) * Math.cos(lng_rad) +
             15.0 * Math.sin(4.0 * lat_rad) * Math.sin(2.0 * lng_rad) +
             8.0 * Math.cos(3.0 * lat_rad)
    
    height
  end
  
  def calculate_egm2008_height(lat, lng)
    # Improved model over EGM96
    base_height = calculate_egm96_height(lat, lng)
    
    # Add higher-order corrections
    lat_rad = lat * Math::PI / 180.0
    lng_rad = lng * Math::PI / 180.0
    
    correction = 3.0 * Math.sin(6.0 * lat_rad) * Math.cos(3.0 * lng_rad) +
                 2.0 * Math.cos(8.0 * lat_rad) * Math.sin(4.0 * lng_rad)
    
    base_height + correction
  end
  
  def calculate_geoid18_height(lat, lng)
    # CONUS-specific high-accuracy model
    unless in_coverage?(lat, lng)
      # Fall back to global model
      return calculate_egm2008_height(lat, lng)
    end
    
    # Simplified GEOID18 approximation
    lat_rad = lat * Math::PI / 180.0
    lng_rad = lng * Math::PI / 180.0
    
    # Regional adjustments for CONUS
    base_height = calculate_egm2008_height(lat, lng)
    
    # Add CONUS-specific corrections
    conus_correction = -2.0 * Math.sin((lat - 40.0) * Math::PI / 20.0) * 
                       Math.cos((lng + 95.0) * Math::PI / 30.0)
    
    base_height + conus_correction
  end
  
  def calculate_geoid12b_height(lat, lng)
    # Legacy CONUS model
    unless in_coverage?(lat, lng)
      return calculate_egm96_height(lat, lng)
    end
    
    # Similar to GEOID18 but with older adjustments
    base_height = calculate_egm96_height(lat, lng)
    
    lat_rad = lat * Math::PI / 180.0
    lng_rad = lng * Math::PI / 180.0
    
    conus_correction = -1.5 * Math.sin((lat - 39.0) * Math::PI / 20.0) * 
                       Math.cos((lng + 96.0) * Math::PI / 32.0)
    
    base_height + conus_correction
  end
end

# Extension to existing coordinate classes to support geoid heights
module GeoidHeightSupport
  def self.included(base)
    base.extend(ClassMethods)
  end
  
  module ClassMethods
    # Add geoid height support to coordinate conversions
    def with_geoid_height(geoid_model = 'EGM2008')
      @geoid_model = geoid_model
      self
    end
    
    def geoid_model
      @geoid_model || 'EGM2008'
    end
  end
  
  # Convert height between vertical datums
  def convert_height_datum(from_datum, to_datum, geoid_model = 'EGM2008')
    return self unless respond_to?(:lat) && respond_to?(:lng) && respond_to?(:alt)
    
    geoid = GeoidHeight.new(geoid_model)
    new_height = geoid.convert_vertical_datum(self.lat, self.lng, self.alt, from_datum, to_datum)
    
    # Return new coordinate with converted height
    new_coord = self.dup
    new_coord.alt = new_height if new_coord.respond_to?(:alt=)
    new_coord
  end
  
  # Get geoid height at this coordinate
  def geoid_height(geoid_model = 'EGM2008')
    return nil unless respond_to?(:lat) && respond_to?(:lng)
    
    geoid = GeoidHeight.new(geoid_model)
    geoid.geoid_height_at(self.lat, self.lng)
  end
  
  # Get orthometric height (MSL height)
  def orthometric_height(geoid_model = 'EGM2008')
    return nil unless respond_to?(:alt) && respond_to?(:lat) && respond_to?(:lng)
    
    geoid = GeoidHeight.new(geoid_model)
    geoid.ellipsoidal_to_orthometric(self.lat, self.lng, self.alt)
  end
  
  # Get ellipsoidal height from orthometric height
  def self.from_orthometric_height(lat, lng, orthometric_height, geoid_model = 'EGM2008')
    geoid = GeoidHeight.new(geoid_model)
    ellipsoidal_height = geoid.orthometric_to_ellipsoidal(lat, lng, orthometric_height)
    ellipsoidal_height
  end
end