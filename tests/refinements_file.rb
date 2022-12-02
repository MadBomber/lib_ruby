#!/usr/bin/env ruby
# tests/refinements_file.rb

require 'minitest/autorun'
require "minitest/reporters"
Minitest::Reporters.use! Minitest::Reporters::DefaultReporter.new

require_relative '../refinements_file.rb'

class TestRefinementsFile < Minitest::Test

  using Refinements

  def setup
    # TODO: Create a data directory to hold a test file
    #       create a test file with known content.
    #       Get the known contents of the test file from
    #       the __DATA__ component of this file.
    #
    # TODO: setup a common regex_hash with all supported
    #       types of keys and values.
  end


  def test_gsub_banger
    # TODO: complete the test
  end


  def test_gsub_banger_with_backup
    # TODO: complete the test
  end


  def test_gsub
    TODO: complete the test
  end


  def test_gsub_with_to_filename
    TODO: complete the test
  end
end

__DATA__
# Known test file content
# TODO: Add specific content to support various test cases

