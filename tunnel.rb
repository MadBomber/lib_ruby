# ~/lib/ruby/tunnel.rb

class Hash
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
end

