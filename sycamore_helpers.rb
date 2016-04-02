require 'sycamore'

module Sycamore
  class Tree
    def string_search(a_string)
      self.each_path.select{|a_path| a_path.join('/').downcase.include?(a_string.downcase)}
    end

    def insert(a_hash_or_tree, an_array_or_path=[])
      a_hash    = Tree == a_hash_or_tree.class ? a_hash_or_tree.to_h : a_hash_or_tree
      a_hash.each_pair do |key, value|
        if Hash == value.class
          insert(value, an_array_or_path.to_a+[key])
        else
          self[an_array_or_path.to_a+[key]] << value
        end
      end
    end

    def merge!(a_thing)
      if Hash == a_thing.class
        @data.merge!(a_thing)
      else
        @data.merge!(a_thing.to_h)
      end
    end
  end
end
