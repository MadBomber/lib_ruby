# lib/ruby/hash_array.rb

class HashArray
  def self.new
    Hash.new{|h,k| h[k] = []}
  end
end
