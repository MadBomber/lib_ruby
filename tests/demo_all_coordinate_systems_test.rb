#!/usr/bin/env ruby

require 'minitest/autorun'

class DemoAllCoordinateSystemsTest < Minitest::Test
  def test_demo_all_coordinate_systems_runs
    out, _ = capture_io do
      load File.expand_path('../../coordinates/demo_all_coordinate_systems.rb', __FILE__)
    end
    assert_match /COMPLETE COORDINATE SYSTEM CONVERSION DEMONSTRATION/, out
  end
end