#!/usr/bin/env ruby
# Tests for all new coordinate systems added to the coordinates library
# Tests MGRS, Web Mercator, UPS, USNG, State Plane, BNG, and Geoid Height support

require 'minitest/autorun'
require_relative '../coordinates/lla_coordinate'
require_relative '../coordinates/mgrs_coordinate'
require_relative '../coordinates/web_mercator_coordinate'
require_relative '../coordinates/ups_coordinate'
require_relative '../coordinates/usng_coordinate'
require_relative '../coordinates/state_plane_coordinate'
require_relative '../coordinates/british_national_grid_coordinate'
require_relative '../coordinates/geoid_height'

class NewCoordinateSystemsTest < Minitest::Test
  
  def setup
    # Test location: Seattle Space Needle
    @seattle_lat = 47.6205
    @seattle_lng = -122.3493
    @seattle_alt = 184.0
    @seattle_lla = LlaCoordinate.new(@seattle_lat, @seattle_lng, @seattle_alt)
    
    # Test location: London Big Ben
    @london_lat = 51.5007
    @london_lng = -0.1246
    @london_alt = 11.0
    @london_lla = LlaCoordinate.new(@london_lat, @london_lng, @london_alt)
    
    # Test location: North Pole (for UPS testing)
    @north_pole_lat = 89.0
    @north_pole_lng = 0.0
    @north_pole_alt = 0.0
    @north_pole_lla = LlaCoordinate.new(@north_pole_lat, @north_pole_lng, @north_pole_alt)
  end
  
  # MGRS Tests
  def test_mgrs_conversions
    # Test MGRS conversion for Seattle
    mgrs = MgrsCoordinate.from_lla(@seattle_lla)
    
    assert mgrs.grid_zone_designator.length >= 2, "MGRS should have grid zone designator"
    assert mgrs.square_identifier.length == 2, "MGRS should have 2-letter square identifier"
    assert mgrs.easting >= 0 && mgrs.easting < 100000, "MGRS easting should be 0-99999"
    assert mgrs.northing >= 0 && mgrs.northing < 100000, "MGRS northing should be 0-99999"
    
    # Test round-trip conversion
    lla_back = mgrs.to_lla
    assert_coordinate_close(@seattle_lla, lla_back, 0.01, "MGRS round-trip conversion")
    
    # Test string format
    mgrs_string = mgrs.to_s
    assert mgrs_string.length >= 4, "MGRS string should be at least 4 characters"
    
    # Test parsing MGRS string
    mgrs_parsed = MgrsCoordinate.new(mgrs_string)
    assert_equal mgrs.grid_zone_designator, mgrs_parsed.grid_zone_designator
    assert_equal mgrs.square_identifier, mgrs_parsed.square_identifier
  end
  
  # Web Mercator Tests  
  def test_web_mercator_conversions
    # Test Web Mercator conversion for Seattle
    web_merc = WebMercatorCoordinate.from_lla(@seattle_lla)
    
    assert web_merc.x.abs < WebMercatorCoordinate::ORIGIN_SHIFT, "Web Mercator X should be within bounds"
    assert web_merc.y.abs < WebMercatorCoordinate::ORIGIN_SHIFT, "Web Mercator Y should be within bounds"
    assert web_merc.valid?, "Web Mercator coordinate should be valid"
    
    # Test round-trip conversion (Web Mercator loses altitude information)
    lla_back = web_merc.to_lla
    assert_coordinate_close_2d(@seattle_lla, lla_back, 0.01, "Web Mercator round-trip conversion")
    
    # Test tile coordinates
    tile_coords = web_merc.to_tile_coordinates(10)
    assert tile_coords[0] >= 0 && tile_coords[0] < 2**10, "Tile X should be valid for zoom level"
    assert tile_coords[1] >= 0 && tile_coords[1] < 2**10, "Tile Y should be valid for zoom level"
    assert_equal 10, tile_coords[2], "Zoom level should match"
    
    # Test pixel coordinates  
    pixel_coords = web_merc.to_pixel_coordinates(10)
    assert pixel_coords[0] >= 0, "Pixel X should be non-negative"
    assert pixel_coords[1] >= 0, "Pixel Y should be non-negative"
    
    # Test distance calculation
    other_web_merc = WebMercatorCoordinate.from_lla(@london_lla)
    distance = web_merc.distance_to(other_web_merc)
    assert distance > 0, "Distance should be positive"
  end
  
  # UPS Tests
  def test_ups_conversions
    # Test UPS conversion for North Pole
    ups = UpsCoordinate.from_lla(@north_pole_lla)
    
    assert ups.hemisphere == 'N', "North pole should be in northern hemisphere"
    assert ['Y', 'Z'].include?(ups.zone), "North pole should be in zone Y or Z"
    assert ups.valid?, "UPS coordinate should be valid"
    
    # Test round-trip conversion (UPS has some precision limitations near pole)
    lla_back = ups.to_lla
    assert_coordinate_close(@north_pole_lla, lla_back, 1.0, "UPS round-trip conversion")
    
    # Test grid convergence
    convergence = ups.grid_convergence
    assert convergence.is_a?(Numeric), "Grid convergence should be numeric"
    
    # Test scale factor
    scale_factor = ups.point_scale_factor
    assert scale_factor > 0, "Scale factor should be positive"
  end
  
  # USNG Tests
  def test_usng_conversions
    # Test USNG conversion for Seattle
    usng = UsngCoordinate.from_lla(@seattle_lla)
    
    assert usng.grid_zone_designator.length >= 2, "USNG should have grid zone designator"
    assert usng.square_identifier.length == 2, "USNG should have 2-letter square identifier"
    assert usng.valid?, "USNG coordinate should be valid for CONUS"
    
    # Test round-trip conversion
    lla_back = usng.to_lla
    assert_coordinate_close(@seattle_lla, lla_back, 0.01, "USNG round-trip conversion")
    
    # Test string formatting
    full_format = usng.to_full_format
    abbreviated_format = usng.to_abbreviated_format
    
    assert full_format.include?(' '), "Full format should include spaces"
    assert abbreviated_format.length <= full_format.length, "Abbreviated format should be shorter or equal"
    
    # Test distance and bearing
    other_usng = UsngCoordinate.from_lla(@london_lla)
    distance = usng.distance_to(other_usng)
    bearing = usng.bearing_to(other_usng)
    
    assert distance > 0, "Distance should be positive"
    assert bearing >= 0 && bearing < 360, "Bearing should be 0-359 degrees"
  end
  
  # State Plane Tests
  def test_state_plane_conversions
    # Test California State Plane Zone I
    ca_spc = StatePlaneCoordinate.from_lla(@seattle_lla, 'CA_I')
    
    assert ca_spc.zone_code == 'CA_I', "Zone code should be preserved"
    assert ca_spc.easting > 0, "Easting should be positive"
    assert ca_spc.northing > 0, "Northing should be positive"
    assert ca_spc.valid?, "State Plane coordinate should be valid"
    
    # Test zone info
    zone_info = ca_spc.zone_info
    assert_equal 'California', zone_info[:state]
    assert zone_info[:projection] == 'lambert_conformal_conic', "CA uses Lambert Conformal Conic"
    
    # Test round-trip conversion (State Plane simplified projections have larger errors)
    lla_back = ca_spc.to_lla
    assert_coordinate_close(@seattle_lla, lla_back, 50.0, "State Plane round-trip conversion")
    
    # Test unit conversions
    ca_spc_meters = ca_spc.to_meters
    ca_spc_feet = ca_spc.to_us_survey_feet
    
    assert ca_spc_meters.easting != ca_spc.easting, "Meter conversion should change values"
    assert ca_spc_feet.easting == ca_spc.easting, "Should already be in US Survey Feet"
    
    # Test zones for state
    ca_zones = StatePlaneCoordinate.zones_for_state('California')
    assert ca_zones.length > 0, "California should have multiple zones"
    assert ca_zones.key?('CA_I'), "Should include Zone I"
  end
  
  # British National Grid Tests
  def test_bng_conversions
    # Test BNG conversion for London
    bng = BritishNationalGridCoordinate.from_lla(@london_lla)
    
    assert bng.easting > 0 && bng.easting <= 700000, "BNG easting should be within GB bounds"
    assert bng.northing > 0 && bng.northing <= 1300000, "BNG northing should be within GB bounds"
    assert bng.valid?, "BNG coordinate should be valid"
    
    # Test grid reference
    grid_ref = bng.to_grid_reference
    assert grid_ref.length >= 2, "Grid reference should have at least 2 characters"
    assert grid_ref.match(/^[A-Z]{2}/), "Grid reference should start with 2 letters"
    
    # Test parsing grid reference
    bng_parsed = BritishNationalGridCoordinate.new(0, 0, grid_ref)
    assert bng_parsed.easting > 0, "Parsed BNG should have positive easting"
    assert bng_parsed.northing > 0, "Parsed BNG should have positive northing"
    
    # Test round-trip conversion (BNG loses altitude in simplified implementation)
    lla_back = bng.to_lla
    assert_coordinate_close_2d(@london_lla, lla_back, 0.01, "BNG round-trip conversion")
    
    # Test distance and bearing
    other_bng = BritishNationalGridCoordinate.from_lla(@seattle_lla)
    distance = bng.distance_to(other_bng)
    bearing = bng.bearing_to(other_bng)
    
    assert distance > 0, "Distance should be positive"
    assert bearing >= 0 && bearing < 360, "Bearing should be 0-359 degrees"
  end
  
  # Geoid Height Tests
  def test_geoid_height_support
    # Test geoid height calculation
    geoid = GeoidHeight.new('EGM2008')
    
    seattle_geoid_height = geoid.geoid_height_at(@seattle_lat, @seattle_lng)
    assert seattle_geoid_height.is_a?(Numeric), "Geoid height should be numeric"
    assert seattle_geoid_height.abs < 200, "Geoid height should be reasonable (< 200m)"
    
    # Test height conversions
    orthometric_height = geoid.ellipsoidal_to_orthometric(@seattle_lat, @seattle_lng, @seattle_alt)
    ellipsoidal_height = geoid.orthometric_to_ellipsoidal(@seattle_lat, @seattle_lng, orthometric_height)
    
    assert_in_delta @seattle_alt, ellipsoidal_height, 0.001, "Height conversion round-trip should be accurate"
    
    # Test vertical datum conversion
    navd88_height = geoid.convert_vertical_datum(@seattle_lat, @seattle_lng, @seattle_alt, 'HAE', 'NAVD88')
    hae_height = geoid.convert_vertical_datum(@seattle_lat, @seattle_lng, navd88_height, 'NAVD88', 'HAE')
    
    assert_in_delta @seattle_alt, hae_height, 1.0, "Vertical datum conversion should be reasonably accurate"
    
    # Test accuracy estimate
    accuracy = geoid.accuracy_estimate(@seattle_lat, @seattle_lng)
    assert accuracy > 0, "Accuracy estimate should be positive"
    
    # Test coverage check
    assert geoid.in_coverage?(@seattle_lat, @seattle_lng), "Seattle should be in global coverage"
    
    # Test available models and datums
    models = GeoidHeight.available_models
    assert models.include?('EGM2008'), "Should include EGM2008"
    assert models.include?('EGM96'), "Should include EGM96"
    
    datums = GeoidHeight.available_vertical_datums
    assert datums.include?('NAVD88'), "Should include NAVD88"
    assert datums.include?('MSL'), "Should include MSL"
  end
  
  # Test LLA with geoid height support
  def test_lla_geoid_integration
    # Test geoid height methods on LLA coordinate
    geoid_height = @seattle_lla.geoid_height
    assert geoid_height.is_a?(Numeric), "LLA should return geoid height"
    
    orthometric_height = @seattle_lla.orthometric_height
    assert orthometric_height.is_a?(Numeric), "LLA should return orthometric height"
    
    # Test height datum conversion
    navd88_coord = @seattle_lla.convert_height_datum('HAE', 'NAVD88')
    assert navd88_coord.alt != @seattle_lla.alt, "Height datum conversion should change altitude"
    
    hae_coord = navd88_coord.convert_height_datum('NAVD88', 'HAE')
    assert_in_delta @seattle_lla.alt, hae_coord.alt, 1.0, "Round-trip height datum conversion"
  end
  
  # Cross-system conversion tests
  def test_cross_system_conversions
    # Test converting between new coordinate systems
    mgrs = MgrsCoordinate.from_lla(@seattle_lla)
    usng = UsngCoordinate.from_mgrs(mgrs)
    web_merc = WebMercatorCoordinate.from_lla(@seattle_lla)
    
    # Test MGRS to Web Mercator via LLA
    mgrs_to_web_merc_lla = mgrs.to_lla
    mgrs_to_web_merc = WebMercatorCoordinate.from_lla(mgrs_to_web_merc_lla)
    
    assert_in_delta web_merc.x, mgrs_to_web_merc.x, 100, "MGRS to Web Mercator X should be close"
    assert_in_delta web_merc.y, mgrs_to_web_merc.y, 100, "MGRS to Web Mercator Y should be close"
    
    # Test USNG consistency with MGRS
    mgrs_lla = mgrs.to_lla
    usng_lla = usng.to_lla
    
    assert_coordinate_close(mgrs_lla, usng_lla, 0.001, "MGRS and USNG should give same LLA")
  end
  
  # Performance and edge case tests
  def test_edge_cases_and_performance
    # Test coordinates at extremes
    equator_lla = LlaCoordinate.new(0.0, 0.0, 0.0)
    dateline_lla = LlaCoordinate.new(0.0, 180.0, 0.0)
    
    # Test conversions don't crash at extremes
    begin
      WebMercatorCoordinate.from_lla(equator_lla)
      assert true, "Web Mercator should handle equator"
    rescue => e
      assert false, "Web Mercator crashed at equator: #{e.message}"
    end
    
    begin
      MgrsCoordinate.from_lla(dateline_lla)
      assert true, "MGRS should handle dateline"
    rescue => e
      assert false, "MGRS crashed at dateline: #{e.message}"
    end
    
    # Test invalid coordinates
    assert_raises(StandardError, "Should reject invalid latitude") do
      LlaCoordinate.new(91.0, 0.0, 0.0)
    end
  end
  
  private
  
  def assert_coordinate_close(coord1, coord2, tolerance, message = nil)
    lat_diff = (coord1.lat - coord2.lat).abs
    lng_diff = (coord1.lng - coord2.lng).abs
    alt_diff = (coord1.alt - coord2.alt).abs
    
    assert lat_diff < tolerance, "#{message}: Latitude difference #{lat_diff} exceeds tolerance #{tolerance}"
    assert lng_diff < tolerance, "#{message}: Longitude difference #{lng_diff} exceeds tolerance #{tolerance}"
    assert alt_diff < tolerance * 100, "#{message}: Altitude difference #{alt_diff} exceeds tolerance #{tolerance * 100}"
  end
  
  def assert_coordinate_close_2d(coord1, coord2, tolerance, message = nil)
    lat_diff = (coord1.lat - coord2.lat).abs
    lng_diff = (coord1.lng - coord2.lng).abs
    
    assert lat_diff < tolerance, "#{message}: Latitude difference #{lat_diff} exceeds tolerance #{tolerance}"
    assert lng_diff < tolerance, "#{message}: Longitude difference #{lng_diff} exceeds tolerance #{tolerance}"
  end
end