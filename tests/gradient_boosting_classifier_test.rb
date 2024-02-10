#!/usr/bin/env ruby
# ~/lib/ruby/tests/gradient_boosting_classifier_test.rb

require 'minitest/autorun'
require 'gradient_boosting_classifier'

class GradientBoostingClassifierTest < Minitest::Test
  def setup
    @classifier = GradientBoostingClassifier.new(n_trees: 3, learning_rate: 0.1, max_tree_depth: 3)
  end

  def test_initialization
    assert_equal 3, @classifier.n_trees
    assert_equal 0.1, @classifier.learning_rate
    assert_equal 3, @classifier.max_tree_depth
    assert_empty @classifier.trees
    assert_nil @classifier.initial_prediction
  end

  # This test assumes binary labels and simple linearly separable data for testing purposes
  def test_train_and_predict
    data = [[1], [2], [3], [4], [5]]
    labels = [0, 0, 1, 1, 1]  # Assume binary labels
    
    @classifier.train(data, labels)
    
    # Ensure trees are trained
    refute_empty @classifier.trees
    assert_equal 3, @classifier.trees.size

    # Basic check to ensure prediction returns binary labels
    prediction = @classifier.predict([1.5])
    assert_includes [0, 1], prediction

    prediction = @classifier.predict([3.5])
    assert_includes [0, 1], prediction
  end
end
