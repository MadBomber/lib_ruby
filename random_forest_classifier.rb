# ~/lib/ruby/random_forest_classifier.rb
#
# See: https://www.fastruby.io/blog/introduction-to-random-forests.html?ck_subscriber_id=791584073

require_relative "decision_tree"

class RandomForestClassifier
  attr_accessor :n_trees, :max_depth, :trees
  
  def initialize(n_trees, max_depth)
    @n_trees = n_trees
    @max_depth = max_depth
    @trees = []
  end

  def train(data, labels)
    @n_trees.times do
      tree = DecisionTree.new
      bootstrapped_data, bootstrapped_labels = bootstrap_sample(data, labels)
      tree.train(bootstrapped_data, bootstrapped_labels, @max_depth)
      @trees << tree
    end
  end

  def predict(sample)
    predictions = @trees.map { |tree| tree.predict(sample, nil) }.compact
    return nil if predictions.empty?
    predictions.group_by(&:itself).values.max_by(&:size).first
  end
  
  private

  def bootstrap_sample(data, labels)
    bootstrapped_data = []
    bootstrapped_labels = []
    n_samples = data.length

    n_samples.times do
      index = rand(n_samples)
      bootstrapped_data << data[index]
      bootstrapped_labels << labels[index]
    end

    [bootstrapped_data, bootstrapped_labels]
  end
end