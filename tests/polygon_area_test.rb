#!/usr/bin/env ruby

require 'minitest/autorun'
require_relative '../coordinates/lla_coordinate'
require_relative '../coordinates/polygon_area'

class PolygonAreaTest < Minitest::Test
  def setup
    @p1 = LlaCoordinate.new(0.0, 0.0, 0.0)
    @p2 = LlaCoordinate.new(0.0, 1.0, 0.0)
    @p3 = LlaCoordinate.new(1.0, 0.0, 0.0)
    @triangle = PolygonArea.new([@p1, @p2, @p3])
  end

  def test_boundary_closed
    assert_equal @p1, @triangle.boundary.first
    assert_equal @p1, @triangle.boundary.last
    assert_equal 4, @triangle.boundary.length
  end

  def test_includes_vertex
    assert @triangle.includes?(@p2)
    assert @triangle.include?(@p3)
  end

  def test_excludes_point_outside
    outside = LlaCoordinate.new(10.0, 10.0, 0.0)
    refute @triangle.includes?(outside)
    assert @triangle.excludes?(outside)
  end

  def test_invalid_initialization
    # Expect uncaught throw for insufficient boundary points
    assert_raises(UncaughtThrowError) { PolygonArea.new([@p1, @p2]) }
  end
end