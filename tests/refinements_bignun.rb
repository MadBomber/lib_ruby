#!/usr/bin/env ruby
# tests/refinements_bignum.rb

require 'minitest/autorun'
require "minitest/reporters"
Minitest::Reporters.use! Minitest::Reporters::DefaultReporter.new

require_relative '../refinements_bignum.rb'

class TestRefinementsFixnum < Minitest::Test

  using Refinements

  def setup
    @number = 934361079326356530741942970523610389 
  end

  def test_to_s
    assert_equal "934361079326356530741942970523610389", @number.to_s
  end

  def test_humanize
    assert_equal "934,361,079,326,356,530,741,942,970,523,610,389", @number.humanize
    assert_equal "934_361_079_326_356_530_741_942_970_523_610_389", @number.humanize('_')
  end

end