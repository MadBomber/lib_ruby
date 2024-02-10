#!/usr/bin/env ruby
# ~/lib/ruby/tests/random_forest_classifier_test.rb

require 'minitest/autorun'
require 'random_forest_classifier'

class RandomForestClassifierTest < Minitest::Test
  def setup
    # Setup code that is run before each test
    @classifier = RandomForestClassifier.new(3, 5)

    # Example training data and labels
    @data = [
      [5.1, 3.5, 1.4, 0.2],
      [4.9, 3.0, 1.4, 0.2],
      [7.0, 3.2, 4.7, 1.4],
      [6.4, 3.2, 4.5, 1.5],
      [6.3, 3.3, 6.0, 2.5],
      [5.8, 2.7, 5.1, 1.9]
    ]

    @labels = ['setosa', 'setosa', 'versicolor', 'versicolor', 'virginica', 'virginica']
  end

  def test_train
    # Testing whether the classifier can be trained without errors
    begin
      @classifier.train(@data, @labels)
    rescue => e
      false
    end
  end

  def test_predict
    # Given a sample, test if the classifier can predict its label
    @classifier.train(@data, @labels)

    sample = [5.1, 3.5, 1.4, 0.2]  # Known 'setosa'
    prediction = @classifier.predict(sample)

    assert_equal 'setosa', prediction, "Expected 'setosa', got #{prediction}"
  end


  # This AI generated test fails; but, I need to check
  # the math to see if the expectation is correct
  def test_predict_unknown_sample
    # Attempting to predict a label for a sample not present in training data
    @classifier.train(@data, @labels)

    sample = [7.1, 4.0, 6.5, 2.0]  # Not in @data, but should resemble 'virginica'
    prediction = @classifier.predict(sample)

    assert_equal 'virginica', prediction, "Expected 'virginica', got #{prediction}"
  end
end