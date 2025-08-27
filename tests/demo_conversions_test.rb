#!/usr/bin/env ruby

require 'minitest/autorun'

class DemoConversionsTest < Minitest::Test
  def test_demo_runs_without_error
    out, _ = capture_io do
      load File.expand_path('../../coordinates/demo_conversions.rb', __FILE__)
    end
    assert_match /Orthogonal Coordinate System Conversions Demo/, out
  end
end