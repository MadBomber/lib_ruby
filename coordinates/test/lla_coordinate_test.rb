require 'minitest/autorun'
require_relative '../lla_coordinate'

class LlaCoordinateTest < Minitest::Test
  def test_to_dms_zero
    coord = LlaCoordinate.new(0, 0, 0)
    expected = "0° 0' 0.00\" N, 0° 0' 0.00\" E, 0.00 m"
    assert_equal expected, coord.to_dms
  end

  def test_to_dms_example
    coord = LlaCoordinate.new(37.7749, -122.419233, 15.3)
    expected = "37° 46' 29.64\" N, 122° 25' 9.24\" W, 15.30 m"
    assert_equal expected, coord.to_dms
  end

  def test_from_dms_zero
    coord = LlaCoordinate.from_dms("0° 0' 0.00\" N, 0° 0' 0.00\" E")
    assert_equal 0.0, coord.lat
    assert_equal 0.0, coord.lng
    assert_equal 0.0, coord.alt
  end

  def test_from_dms_example
    dms = "37° 46' 29.64\" N, 122° 25' 9.24\" W, 15.30 m"
    coord = LlaCoordinate.from_dms(dms)
    assert_in_delta 37.7749, coord.lat, 1e-6
    assert_in_delta -122.419233, coord.lng, 1e-6
    assert_in_delta 15.30, coord.alt, 1e-6
  end

  def test_roundtrip_negative_altitude
    original = LlaCoordinate.new(-10.341666, 40.85, -5.5)
    dms = original.to_dms
    coord = LlaCoordinate.from_dms(dms)
    assert_in_delta original.lat, coord.lat, 1e-6
    assert_in_delta original.lng, coord.lng, 1e-6
    assert_in_delta original.alt, coord.alt, 1e-6
  end
end