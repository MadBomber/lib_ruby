require 'sycamore'

module Sycamore
  class Tree
    def string_search(a_string_or_convertable_to_string)
      a_string = a_string_or_convertable_to_string.to_s
      self.each_path.select{|a_path| a_path.join('/').downcase.include?(a_string.downcase)}
    end

    def insert(a_hash_or_tree, an_array_or_path=[])
      a_hash    = a_hash_or_tree.to_h
      a_hash.each_pair do |key, value|
        if Hash == value.class
          insert(value, an_array_or_path.to_a+[key])
        else
          self[an_array_or_path.to_a+[key]] << value
        end
      end
    end

    alias merge! insert

  end # class Tree
end # module Sycamore

