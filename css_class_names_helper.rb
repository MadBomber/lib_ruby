# lib/ruby/css_class_names_helper
# frozen_string_literal: true
# Article: https://rails.readandwrite.io/start-using-rails-class_names-helper-today/
##
module CssClassNamesHelper
  #
  # Build a list of conditional class names
  #
  # @param [mixed] *args
  #
  # @return [string] class names based on the conditions
  #
  def class_names(*args)
    safe_join(conditional_class_names(*args), ' ')
  end

  private

  #
  # Conditional class names
  #
  # @param [mixed] *args
  #
  # @return [string]
  #
  def conditional_class_names(*args)
    # Define an array to store the output to
    class_names = []

    # Loop through each argument
    args.each do |value|
      # Move on unless the value is present
      next unless value.present?

      # Case statement to determine the value type
      case value
      # If the value is a hash, loop through the key and value to ensure it is not empty, false or invalid
      when Hash
        # Remove those with empty values and use the keys for class names
        class_names << value.delete_if { |_key, val| !val }.keys
      # If the value is an array, remove the empty elements
      when Array
        # Call itself to process the presence of array values
        class_names << conditional_class_names(*value).presence
      # Otherwise, convert to a string if the value is present
      else
        # Convert to string unless it's numeric, class names must start with letters
        class_names << value.to_s unless value.is_a?(Numeric)
      end
    end

    class_names.compact.flatten
  end
end # module CssClassNamesHelper

