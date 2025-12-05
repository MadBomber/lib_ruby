# frozen_string_literal: true

require_relative "test_helper"

Dir["#{__dir__}/**/*_test.rb"].each { |f| require f }
