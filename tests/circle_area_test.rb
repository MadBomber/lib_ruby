#!/usr/bin/env ruby

require 'minitest/autorun'
require_relative '../coordinates/lla_coordinate'
require_relative '../coordinates/circle_area'

class CircleAreaTest < Minitest::Test
  def setup
    @center = LlaCoordinate.new(0.0, 0.0, 0.0)
  end

  def test_includes_same_point
    circle = CircleArea.new(@center, 0)
    assert circle.includes?(@center)
    assert circle.include?(@center)
    refute circle.excludes?(@center)
    refute circle.exclude?(@center)
  end

  def test_excludes_point_outside
    # Point ~111 km east of origin at equator (longitude diff 1°)
    far_point = LlaCoordinate.new(0.0, 1.0, 0.0)
    circle = CircleArea.new(@center, 100) # 100 meters
    refute circle.includes?(far_point)
    assert circle.excludes?(far_point)
  end
end