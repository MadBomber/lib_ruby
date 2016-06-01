module Hamming

  def self.distance(a_string, b_string)
    return 0 if a_string === b_string
    pair = [a_string.to_s, b_string.to_s]
    set_strand_position_by_length(pair)
    count_the_distance(pair)
  end

  module_function
  def self.count_the_distance(pair)
    pair.entries.map(&:chars).inject(:zip).select{|a,b| a!=b}.count
  end

  def self.set_strand_position_by_length(pair)
    pair.swap! if pair.inject{|a,b|a.length>b.length}
  end

end # module Hamming

