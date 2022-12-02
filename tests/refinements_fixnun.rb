#!/usr/bin/env ruby
# tests/refinements_fixnum.rb

require 'minitest/autorun'
require "minitest/reporters"
Minitest::Reporters.use! Minitest::Reporters::DefaultReporter.new

require_relative '../refinements_fixnum.rb'

class TestRefinementsFixnum < Minitest::Test

  using Refinements

  def setup
    @number = 657_435_289
  end

  def test_to_s
    assert_equal "657435289", @number.to_s
  end

  def test_humanize
    assert_equal "657,435,289", @number.humanize
    assert_equal "657_435_289", @number.humanize('_')
  end

end