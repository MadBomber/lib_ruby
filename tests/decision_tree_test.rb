# lib/ruby/tests/decision_tree_test.rb

require 'minitest/autorun'
require_relative '../decision_tree'

class DecisionTreeTest < Minitest::Test

  def setup
    @csv_file_path = "decision_tree_data.csv"
    @tree = DecisionTree.new
    @training_data, @labels, @features = DecisionTree.import(@csv_file_path)
  end

  def test_label_assigned_to_pure_node
    @tree.train([@training_data.first], [@labels.first], 1)
    assert_equal @labels.first, @tree.label
  end

  def test_split_feature_and_threshold_for_training_data
    @tree.train(@training_data, @labels, 1)
    refute_nil @tree.split_feature
    refute_nil @tree.split_threshold
  end

  def test_split_results_in_children
    @tree.train(@training_data, @labels, 2) # Use max_depth of 2
    refute_nil @tree.left
    refute_nil @tree.right
  end

  def test_prediction_at_leaf_returns_label
    @tree.train([@training_data.first], [@labels.first], 1)
    assert_equal @labels.first, @tree.predict(@training_data.first, 'Default')
  end

  def test_prediction_without_training_returns_default
    assert_equal 'Default', @tree.predict(@training_data.first, 'Default')
  end

  def test_prediction_traverses_tree_correctly
    @tree.train(@training_data, @labels, 2) # Use max_depth of 2
    assert_includes @labels, @tree.predict(@training_data.first, 'Default')
  end

  def test_gini_impurity_calculation
    first_index = 0
    # Get index of first instance with same label as first data instance
    same_label_index = @labels.index(@labels[first_index])
    expected = 0.0
    result = @tree.send(:calculate_gini, [first_index, same_label_index], @labels)
    assert_in_delta expected, result, 0.001
  end

  def test_weighted_gini_impurity_calculation
    first_index = 0
    second_index = 1 # The second data sample may have a different label
    l_indices = [first_index]
    r_indices = [second_index]
    num_samples = @training_data.size.to_f
    l_weight = l_indices.size / num_samples
    r_weight = r_indices.size / num_samples
    expected_value = l_weight * @tree.send(:calculate_gini, l_indices, @labels) +
                     r_weight * @tree.send(:calculate_gini, r_indices, @labels)
    assert_in_delta expected_value, @tree.send(:calc_weighted_gini, l_indices, r_indices, @labels, num_samples), 0.001
  end




  ###############################################
  ## Class Method Tests

  def test_import_from_csv
    csv_file_path = "decision_tree_data.csv"
    data, labels, features = DecisionTree.import(csv_file_path)

    expected_features = ['Outlook', 'Temperature', 'Humidity', 'Wind']
    expected_labels = ['False', 'False', 'True', 'True', 'True', 'False', 'True', 'False', 'True', 'True', 'True', 'True', 'True', 'False']
    expected_first_data_row = ['Sunny', 'High', 'High', 'Weak']
    expected_data_size = expected_labels.size

    assert_equal expected_features, features, "The features should match the headers of the CSV, except the label"
    assert_equal expected_labels, labels, "The labels should match the last column of the CSV"
    assert_equal expected_first_data_row, data.first, "The first row of data should match the first row of the CSV, excluding the label"
    assert_equal expected_data_size, data.size, "The number of data rows should match the number of rows in the CSV, excluding the header"
  end
end

