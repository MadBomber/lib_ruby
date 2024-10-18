##############################################
###
##  File: refinements_hash.rb
##  Desc: some common refinements on the Hash class
#
require 'set'

module Refinements

  refine ::Hash do

    # search a 2-level deep hash looking for entries (keys) whose sub-key and value
    # are equal to (==) the values given.  If target value is an Array uses
    # Set#subset? to determine equality.
    def where(options={})
      return self if options.empty?  ||  options.class != Hash
      self.select {|key, value|
        result = true
        options.each_pair do |field, field_value|
          if Array == value[field].class
            result &&= Array(field_value).to_set.subset?(value[field].to_set)
          else
            result &&= value[field] == field_value
          end
        end
        result
      }
    end # def where(options)


    # The `tunnel` method searches through a nested hash and its arrays to find 
    # the value associated with the specified target_key. This method uses 
    # a breadth-first search strategy to explore all levels of nesting 
    # within the hash structure.
    #
    # Parameters:
    # target_key: The key whose associated value we wish to find within the 
    #             nested hash/structures.
    #
    # Returns:
    # - The value associated with target_key if found.
    # - nil if the target_key is not present in the hash or its nested structures.

    def tunnel(target_key)
      queue = [self] # Initialize the queue with the current hash

      until queue.empty?
        current = queue.shift # Dequeue the front hash

        # Check if the current hash contains the target key
        return current[target_key] if current.key?(target_key)

        # Enqueue sub-hashes and arrays to the queue for further searching
        current.each_value do |value|
          case value
          when Hash
            queue << value
          when Array
            queue.concat(value.select { |v| v.is_a?(Hash) }) # Add sub-hashes from the array
          end
        end
      end

      nil # Return nil if the key is not found
    end

    # This method allows for binding the current hash to a given 
    # transformation or computation defined in a block. It short-circuits 
    # if a result is already present, preventing unnecessary computations.
    #
    # Usage:
    #   result_hash = { input: some_value }.bind { |input| { result: input * 2 } }
    #
    # Parameters:
    #   &block: A block that performs the necessary operations on the input 
    #            value and returns a hash that merges into the original hash.
    #
    # Returns:
    #   A new hash that includes the result of the block operation under the 
    #   key `:result`. If the `:result` key is already present, returns 
    #   the original hash unmodified.
    #
    def bind
      # Short-circuit if we already have a result.
      return self if self[:result]
 
      # Otherwise, run the given block.
      result = yield self[:input]
      merge(result:)
    end


    # This method extracts the value associated with the `:result` key 
    # from the hash. It's a way to retrieve the output of a previous 
    # operation that was performed with the `bind` method.
    #
    # Usage:
    #   result_value = result_hash.unwrap
    #
    # Returns:
    #   The value stored under the `:result` key if it exists; otherwise, 
    #   returns nil. This method allows easy retrieval of the result 
    #   after applying a transformation using `bind`.
    #
    def unwrap
      self[:result]
    end


  end # refine ::Hash do
end # module Refinements
