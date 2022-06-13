#!/usr/bin/env ruby
# tests/simple_feature_flags_test.rb

require 'minitest/autorun'
require "minitest/reporters"

Minitest::Reporters.use! Minitest::Reporters::DefaultReporter.new

require_relative '../simple_feature_flags.rb'
include SimpleFeatureFlags


class TestSimpleFeatureFlags < Minitest::Test

  def setup
    ENV['SAY_HELLO'] = 'any value'
  end

  def test_enabled
    assert feature_enabled? :say_hello
    assert feature_enabled? 'say_hello'
    assert feature_enabled? 'Say_Hello'
  end


  def test_not_enabled
    assert_nil feature_enabled? 'flkanfjwljshfq;ehf'
  end
end
