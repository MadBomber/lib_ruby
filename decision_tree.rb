# lib/ruby/decision_tree.rb
# See: https://www.fastruby.io/blog/cart-decision-tree-in-ruby.html

require 'csv'

class DecisionTree
  attr_accessor :left, :right, :split_feature, :split_threshold, :label

  def initialize
    @left = nil  # left child node
    @right = nil  # right child node
    @split_feature = nil  # feature to split on
    @split_threshold = nil  # threshold for the split
    @label = nil  # label for the leaf nodes
  end

  def train(data, labels, max_depth)
    if labels.uniq.length == 1
      @label = labels[0]
      return
    end

    if max_depth == 0 || data.empty?
      @label = labels.max_by { |label| labels.count(label) }
      return
    end

    num_samples = data.length
    num_features = data[0].length
    best_gini = 1.0
    best_split_feature = nil
    best_split_threshold = nil
    l_data = nil
    l_labels = nil
    r_data = nil
    r_labels = nil

    (0...num_features).each do |f_index|
      feature_values = data.map { |x| x[f_index] }
      feature_values.uniq.each do |threshold|
        l_indices = data.each_index.select do |i|
          data[i][f_index] <= threshold
        end
        r_indices = data.each_index.select do |i|
          data[i][f_index] > threshold
        end
        weighted_gini = calc_weighted_gini(l_indices, r_indices, labels, num_samples)

        if weighted_gini < best_gini
          best_gini = weighted_gini
          best_split_feature = f_index
          best_split_threshold = threshold
          l_data = []
          l_labels = []
          r_data = []
          r_labels = []
          l_indices.each do |i|
            l_data << data[i]
            l_labels << labels[i]
          end
          r_indices.each do |i|
            r_data << data[i]
            r_labels << labels[i]
          end
        end
      end
    end

    if best_gini < 1.0
      # If a split reduces the Gini impurity,
      # create left and right child nodes and continue training.
      @split_feature = best_split_feature
      @split_threshold = best_split_threshold
      @left = DecisionTree.new
      @right = DecisionTree.new
      @left.train(l_data, l_labels, max_depth - 1)
      @right.train(r_data, r_labels, max_depth - 1)
    else
      # If the best split doesn't reduce Gini impurity,
      # assign the most frequent label to the node.
      @label = labels.max_by { |label| labels.count(label) }
    end
  end

  def predict(sample, default_label)
    # If it's a leaf node, return the label.
    return @label if @label

    # If not a leaf node, check the splitting criteria.
    if @split_feature.nil? || @split_threshold.nil? || sample[@split_feature].nil?
      return default_label
    end

    if sample[@split_feature] <= @split_threshold
      return @left.predict(sample, default_label) if @left
    else
      return @right.predict(sample, default_label) if @right
    end
  end

  private

  def calculate_gini(indices, labels) 
    return 0.0 if indices.empty?
    s_labels = indices.map { |i| labels[i] }
    # Gini(D) = 1 - Σ (p_i)^2
    1.0 - s_labels.group_by(&:itself).values.sum { |v| (v.length.to_f / s_labels.length)**2 }
  end

  def calc_weighted_gini(l_indices, r_indices, labels, num_samples)
    l_weight =  l_indices.length.to_f / num_samples
    r_weight =  r_indices.length.to_f / num_samples
    gini_left = calculate_gini(l_indices, labels)
    gini_right = calculate_gini(r_indices, labels)
    l_weight * gini_left + r_weight * gini_right
  end

  ###############################################
  ## Class Methods

  # Define a method to import from CSV
  def self.import(csv_file_path)
    data = []
    labels = []
    features = nil

    CSV.foreach(csv_file_path, headers: true) do |row|
      # Convert the row to a hash
      row_data = row.to_h
      
      # Extract features from the headers once
      if features.nil?
        features = row_data.keys[0...-1]  # Assume the last column is the label
      end
      
      # Extract feature values and label for each row
      data << features.map { |feature| row_data[feature] }
      labels << row_data.values.last
    end

    return data, labels, features
  end 
end

__END__

csv_file_path = "tests/decision_tree_data.csv"


# Import data and labels from CSV
training_data, labels, features = DecisionTree.import(csv_file_path)

# Creating an instance of DecisionTree
tree = DecisionTree.new

# Train tree using the imported data and labels
tree.train(training_data, labels, max_depth: 3)

# Now the `tree` is trained and can be used for predictions
