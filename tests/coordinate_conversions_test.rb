#!/usr/bin/env ruby

require 'minitest/autorun'
require_relative '../coordinates/lla_coordinate'
require_relative '../coordinates/ecef_coordinate'
require_relative '../coordinates/enu_coordinate'
require_relative '../coordinates/ned_coordinate'
require_relative '../coordinates/utm_coordinate'

class CoordinateConversionsTest < Minitest::Test

  def setup
    # Test point: Seattle Space Needle
    @test_lat = 47.6205
    @test_lng = -122.3493
    @test_alt = 184.0  # meters
    
    @lla = LlaCoordinate.new(@test_lat, @test_lng, @test_alt)
  end

  # Test LLA ↔ ECEF conversions
  def test_lla_to_ecef_and_back
    ecef = @lla.to_ecef
    
    # ECEF coordinates should be reasonable for Seattle
    assert ecef.x < 0, "X should be negative for Seattle"
    assert ecef.y < 0, "Y should be negative for Seattle"  
    assert ecef.z > 0, "Z should be positive for northern hemisphere"
    
    # Convert back to LLA
    lla_back = ecef.to_lla
    
    # Should be very close to original
    assert_in_delta @test_lat, lla_back.lat, 1e-10
    assert_in_delta @test_lng, lla_back.lng, 1e-10
    assert_in_delta @test_alt, lla_back.alt, 1e-6
  end

  def test_ecef_from_lla_class_method
    ecef1 = @lla.to_ecef
    ecef2 = EcefCoordinate.from_lla(@lla)
    
    assert_equal ecef1, ecef2
  end

  def test_lla_from_ecef_class_method
    ecef = @lla.to_ecef
    lla1 = ecef.to_lla
    lla2 = LlaCoordinate.from_ecef(ecef)
    
    assert_equal lla1, lla2
  end

  # Test LLA ↔ UTM conversions
  def test_lla_to_utm_and_back
    utm = @lla.to_utm
    
    # Seattle should be in UTM Zone 10N
    assert_equal 10, utm.zone
    assert_equal 'N', utm.hemisphere
    
    # UTM coordinates should be reasonable
    assert utm.easting > 0
    assert utm.northing > 0
    assert_equal @test_alt, utm.altitude
    
    # Convert back to LLA
    lla_back = utm.to_lla
    
    # Should be close to original (UTM has some projection error)
    assert_in_delta @test_lat, lla_back.lat, 1e-6
    assert_in_delta @test_lng, lla_back.lng, 1e-6
    assert_in_delta @test_alt, lla_back.alt, 1e-6
  end

  # Test local coordinate conversions
  def test_lla_to_enu_and_back
    # Create a reference point slightly different from test point
    ref_lla = LlaCoordinate.new(@test_lat + 0.001, @test_lng - 0.001, @test_alt - 10)
    
    enu = @lla.to_enu(ref_lla)
    
    # ENU coordinates should make sense
    assert enu.e > 0, "East should be positive (test point is east of reference)"
    assert enu.n < 0, "North should be negative (test point is south of reference)"
    assert enu.u > 0, "Up should be positive (test point is higher than reference)"
    
    # Convert back to LLA
    lla_back = enu.to_lla(ref_lla)
    
    # Should be very close to original
    assert_in_delta @test_lat, lla_back.lat, 1e-8
    assert_in_delta @test_lng, lla_back.lng, 1e-8
    assert_in_delta @test_alt, lla_back.alt, 1e-3
  end

  def test_lla_to_ned_and_back
    # Create a reference point slightly different from test point
    ref_lla = LlaCoordinate.new(@test_lat + 0.001, @test_lng - 0.001, @test_alt - 10)
    
    ned = @lla.to_ned(ref_lla)
    
    # NED coordinates should make sense
    assert ned.n < 0, "North should be negative (test point is south of reference)"
    assert ned.e > 0, "East should be positive (test point is east of reference)"
    assert ned.d < 0, "Down should be negative (test point is higher than reference)"
    
    # Convert back to LLA
    lla_back = ned.to_lla(ref_lla)
    
    # Should be very close to original
    assert_in_delta @test_lat, lla_back.lat, 1e-8
    assert_in_delta @test_lng, lla_back.lng, 1e-8
    assert_in_delta @test_alt, lla_back.alt, 1e-3
  end

  # Test ENU ↔ NED conversions
  def test_enu_ned_conversion
    ref_lla = LlaCoordinate.new(@test_lat, @test_lng, @test_alt)
    target_lla = LlaCoordinate.new(@test_lat + 0.001, @test_lng + 0.001, @test_alt + 10)
    
    enu = target_lla.to_enu(ref_lla)
    ned = target_lla.to_ned(ref_lla)
    
    # Convert ENU to NED
    ned_from_enu = enu.to_ned
    
    # Should match
    assert_in_delta ned.n, ned_from_enu.n, 1e-10
    assert_in_delta ned.e, ned_from_enu.e, 1e-10
    assert_in_delta ned.d, ned_from_enu.d, 1e-10
    
    # Convert back
    enu_from_ned = ned.to_enu
    
    assert_in_delta enu.e, enu_from_ned.e, 1e-10
    assert_in_delta enu.n, enu_from_ned.n, 1e-10
    assert_in_delta enu.u, enu_from_ned.u, 1e-10
  end

  # Test coordinate system consistency
  def test_coordinate_system_consistency
    # Test that going through multiple coordinate systems yields consistent results
    
    # LLA -> ECEF -> ENU -> NED -> ECEF -> LLA
    ref_lla = LlaCoordinate.new(@test_lat - 0.01, @test_lng + 0.01, @test_alt - 100)
    
    ecef1 = @lla.to_ecef
    enu = ecef1.to_enu(ref_lla.to_ecef, ref_lla)
    ned = enu.to_ned
    ecef2 = ned.to_ecef(ref_lla.to_ecef, ref_lla)
    lla_final = ecef2.to_lla
    
    # Should be very close to original
    assert_in_delta @test_lat, lla_final.lat, 1e-8
    assert_in_delta @test_lng, lla_final.lng, 1e-8
    assert_in_delta @test_alt, lla_final.alt, 1e-3
  end

  # Test boundary conditions
  def test_equator_conversions
    equator_lla = LlaCoordinate.new(0.0, 0.0, 0.0)
    
    # Should convert without error
    ecef = equator_lla.to_ecef
    assert ecef.x > 0
    assert_equal 0.0, ecef.y, 1e-10
    assert_equal 0.0, ecef.z, 1e-10
    
    # Convert back
    lla_back = ecef.to_lla
    assert_in_delta 0.0, lla_back.lat, 1e-10
    assert_in_delta 0.0, lla_back.lng, 1e-10
    assert_in_delta 0.0, lla_back.alt, 1e-6
  end

  def test_poles_conversions
    north_pole = LlaCoordinate.new(90.0, 0.0, 0.0)
    south_pole = LlaCoordinate.new(-90.0, 0.0, 0.0)
    
    # North pole
    ecef_n = north_pole.to_ecef
    assert_in_delta 0.0, ecef_n.x, 1e-6
    assert_in_delta 0.0, ecef_n.y, 1e-6
    assert ecef_n.z > 0
    
    lla_n_back = ecef_n.to_lla
    assert_in_delta 90.0, lla_n_back.lat, 1e-6
    
    # South pole
    ecef_s = south_pole.to_ecef
    assert_in_delta 0.0, ecef_s.x, 1e-6
    assert_in_delta 0.0, ecef_s.y, 1e-6
    assert ecef_s.z < 0
    
    lla_s_back = ecef_s.to_lla
    assert_in_delta -90.0, lla_s_back.lat, 1e-6
  end

  # Test distance calculations
  def test_distance_calculations
    lla1 = LlaCoordinate.new(47.6205, -122.3493, 184.0)  # Seattle Space Needle
    lla2 = LlaCoordinate.new(47.6097, -122.3331, 56.0)   # Pioneer Square
    
    # Convert to ECEF and calculate distance
    ecef1 = lla1.to_ecef
    ecef2 = lla2.to_ecef
    ecef_distance = ecef1.distance_to(ecef2)
    
    # Distance should be reasonable (about 1.5 km)
    assert ecef_distance > 1000
    assert ecef_distance < 2000
    
    # Test ENU distance
    enu2 = lla2.to_enu(lla1)
    enu_origin = EnuCoordinate.new(0, 0, 0)
    enu_distance = enu_origin.distance_to(enu2)
    
    # Should be close to ECEF distance
    assert_in_delta ecef_distance, enu_distance, 10.0
  end

  # Test error handling
  def test_invalid_coordinates
    assert_raises(ArgumentError) { LlaCoordinate.new(91.0, 0.0, 0.0) }  # Invalid latitude
    assert_raises(ArgumentError) { LlaCoordinate.new(-91.0, 0.0, 0.0) } # Invalid latitude
    assert_raises(ArgumentError) { LlaCoordinate.new(0.0, 181.0, 0.0) }  # Invalid longitude
    assert_raises(ArgumentError) { LlaCoordinate.new(0.0, -181.0, 0.0) } # Invalid longitude
  end

  def test_invalid_utm_parameters
    assert_raises(ArgumentError) { UtmCoordinate.new(500000, 5000000, 0, 0, 'N') }   # Invalid zone
    assert_raises(ArgumentError) { UtmCoordinate.new(500000, 5000000, 0, 61, 'N') }  # Invalid zone
    assert_raises(ArgumentError) { UtmCoordinate.new(500000, 5000000, 0, 10, 'X') }  # Invalid hemisphere
    assert_raises(ArgumentError) { UtmCoordinate.new(-100, 5000000, 0, 10, 'N') }    # Invalid easting
    assert_raises(ArgumentError) { UtmCoordinate.new(500000, -100, 0, 10, 'N') }     # Invalid northing
  end

  def test_type_checking
    lla = LlaCoordinate.new(47.6205, -122.3493, 184.0)
    ecef = EcefCoordinate.new(1000000, 2000000, 3000000)
    
    # Should raise errors for wrong types
    assert_raises(ArgumentError) { LlaCoordinate.from_ecef("not an ecef") }
    assert_raises(ArgumentError) { lla.to_enu("not an lla") }
    assert_raises(ArgumentError) { ecef.distance_to("not an ecef") }
  end

  # Test array initialization
  def test_array_initialization
    lla_array = LlaCoordinate.new([47.6205, -122.3493, 184.0])
    lla_params = LlaCoordinate.new(47.6205, -122.3493, 184.0)
    
    assert_equal lla_params.lat, lla_array.lat
    assert_equal lla_params.lng, lla_array.lng
    assert_equal lla_params.alt, lla_array.alt
    
    ecef_array = EcefCoordinate.new([1000000, 2000000, 3000000])
    ecef_params = EcefCoordinate.new(1000000, 2000000, 3000000)
    
    assert_equal ecef_params.x, ecef_array.x
    assert_equal ecef_params.y, ecef_array.y
    assert_equal ecef_params.z, ecef_array.z
  end

  # Test utility methods
  def test_coordinate_utility_methods
    lla = LlaCoordinate.new(47.6205, -122.3493, 184.0)
    
    # to_s method
    str = lla.to_s
    assert_includes str, "47.6205"
    assert_includes str, "-122.3493"
    assert_includes str, "184.0"
    
    # to_a method
    array = lla.to_a
    assert_equal [47.6205, -122.3493, 184.0], array
    
    # Equality
    lla2 = LlaCoordinate.new(47.6205, -122.3493, 184.0)
    assert_equal lla, lla2
    
    lla3 = LlaCoordinate.new(47.6206, -122.3493, 184.0)
    refute_equal lla, lla3
  end

  def test_bearing_calculations
    # Test ENU bearing calculation
    origin = EnuCoordinate.new(0, 0, 0)
    east_point = EnuCoordinate.new(100, 0, 0)    # Due east
    north_point = EnuCoordinate.new(0, 100, 0)   # Due north
    ne_point = EnuCoordinate.new(100, 100, 0)    # Northeast
    
    assert_in_delta 90.0, origin.bearing_to(east_point), 1e-10     # 90° for due east
    assert_in_delta 0.0, origin.bearing_to(north_point), 1e-10     # 0° for due north
    assert_in_delta 45.0, origin.bearing_to(ne_point), 1e-10       # 45° for northeast
  end
end