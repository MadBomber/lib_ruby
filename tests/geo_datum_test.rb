#!/usr/bin/env ruby

require 'minitest/autorun'
require_relative '../coordinates/geo_datum'

class GeoDatumTest < Minitest::Test
  def test_get_known
    info = GeoDatum.get('wgs84')
    assert_equal 'WGS84', info['name']
    assert info['a'] > 0
    assert info['e2'] >= 0
  end

  def test_initialize_known
    datum = GeoDatum.new('wgs84')
    assert_equal 'WGS84', datum.name
    assert_in_delta 6378137.0, datum.a, 1e-6
    assert_in_delta 0.00669437999014132, datum.e2, 1e-12
  end

  def test_list_and_dump
    # Ensure list and dump do not raise errors
    assert_output(nil, nil) { GeoDatum.list }
    assert_output(nil, nil) { GeoDatum.dump }
  end

  def test_deg2rad_rad2deg
    assert_in_delta Math::PI, rad2deg(deg2rad(180)), 1e-10
  end
end