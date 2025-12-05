# frozen_string_literal: true

require_relative "test_helper"

Dir.glob(File.join(__dir__, "**", "*_test.rb"))
  .reject { |f| f.include?("/controllers/") }
  .sort
  .each { |f| require f }
