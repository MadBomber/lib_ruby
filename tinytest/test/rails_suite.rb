# frozen_string_literal: true

require_relative "rails_helper"

Dir.glob(File.join(__dir__, "controllers", "**", "*_test.rb"))
  .sort
  .each { |f| require f }
