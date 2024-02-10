# lib/ruby/gradient_boosting_classifier.rb
#
# See: https://www.fastruby.io/blog/introduction-to-gradient-boosting.html?ck_subscriber_id=791584073

require_relative "decision_tree"

class GradientBoostingClassifier
  attr_accessor :n_trees, :learning_rate, :max_tree_depth, :trees, :initial_prediction

  def initialize(max_tree_depth: 3, n_trees: 100, learning_rate: 0.1)
    @n_trees = n_trees
    @learning_rate = learning_rate
    @max_tree_depth = max_tree_depth
    @trees = []
    @initial_prediction = nil
  end
  
  def train
    positive_probability = labels.count(1).to_f / labels.size
    @initial_prediction = Math.log(positive_probability / (1 - positive_probability))
    residuals = Array.new(labels.size, @initial_prediction)

    @n_trees.times do
      probabilities = residuals.map { |log_odds| 1.0 / (1.0 + Math.exp(-log_odds)) }

      pseudo_residuals = labels.zip(probabilities).map { |y, prob| y - prob }

      tree = DecisionTree.new
      tree.train(data, pseudo_residuals, max_tree_depth)
      @trees << tree

      data.each_with_index do |sample, index|
        tree_prediction = tree.predict(sample)
        residuals[index] += @learning_rate * tree_prediction
      end
    end
  end

  def predict(sample)
    log_odds = @initial_prediction
    @trees.each do |tree|
      prediction = tree.predict(sample, 0)
      log_odds += @learning_rate * prediction
    end

    probability = 1.0 / (1.0 + Math.exp(-log_odds))
    probability >= 0.5 ? 1 : 0
  end
end
