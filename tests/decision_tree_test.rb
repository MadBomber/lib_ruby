# lib/ruby/tests/decision_tree_test.rb

require 'minitest/autorun'
require_relative '../decision_tree'

class DecisionTreeTest < Minitest::Test
  def setup
    @tree = DecisionTree.new
    @training_data = [
      [1, 2], [3, 4], [5, 6], [7, 8]
    ]
    @labels = [
      'A', 'B', 'A', 'B'
    ]
  end

  def test_label_assigned_to_pure_node
    @tree.train([[1]], ['A'], 1)
    assert_equal 'A', @tree.label
  end

  def test_split_feature_and_threshold_for_training_data
    @tree.train(@training_data, @labels, 1)
    refute_nil @tree.split_feature
    refute_nil @tree.split_threshold
  end

  def test_split_results_in_children
    @tree.train(@training_data, @labels, 1)
    refute_nil @tree.left
    refute_nil @tree.right
  end

  def test_prediction_at_leaf_returns_label
    @tree.train([[1]], ['A'], 1)
    assert_equal 'A', @tree.predict([1], 'Default')
  end

  def test_prediction_without_training_returns_default
    assert_equal 'Default', @tree.predict([1], 'Default')
  end

  def test_prediction_traverses_tree_correctly
    @tree.train(@training_data, @labels, 1)
    assert_includes ['A', 'B'], @tree.predict([1,2], 'Default')
  end

  def test_gini_impurity_calculation
    expected  = 0.0
    result    = @tree.send(:calculate_gini, 
                  [0,2], 
                  ['A', 'A']
                )
    assert_in_delta expected, result, 0.001
  end

  # def test_weighted_gini_impurity_calculation
  #   l_indices = [0,2]
  #   r_indices = [1,3]
  #   expected_value = (@tree.send(:calculate_gini, l_indices, @labels) + @tree.send(:calculate_gini, r_indices, @labels)) / 2.0
  #   assert_in_delta expected_value, @tree.send(:calc_weighted_gini, l_indices, r_indices, @labels, @training_data.size), 0.001
  # end

  def test_weighted_gini_impurity_calculation
    l_indices = [0,2]
    r_indices = [1,3]
    num_samples = @training_data.size.to_f
    l_weight = l_indices.size / num_samples
    r_weight = r_indices.size / num_samples
    expected_value = l_weight * @tree.send(:calculate_gini, l_indices, @labels) +
                     r_weight * @tree.send(:calculate_gini, r_indices, @labels)
    assert_in_delta expected_value, @tree.send(:calc_weighted_gini, l_indices, r_indices, @labels, num_samples), 0.001
  end
    
end

