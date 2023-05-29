# ~/lib/ruby/combine_ranges.rb

# arr is an Array o f arrays.  Each entry
# represents and integer range where the
# first value is the min and the last value is the
# max of the range.
#
# Returns an Array with no overlaps and
# the least number of ranges.
#
def combine_ranges(arr)
  # Sort the array by the first element of each subarray
  arr.sort_by! { |range| range[0] }

  # Initialize an empty result array and a current range variable
  result = []
  current_range = arr[0]

  # Iterate through the sorted array
  arr[1..-1].each do |range|
    # If the current range overlaps with the next range or the max of the 
    # current range is one less than the min of the next range, combine them
    #
    if current_range[1] >= range[0] - 1
      current_range[1] = [current_range[1], range[1]].max
    else
      result << current_range
      current_range = range
    end
  end

  # Add the last range to the result array
  result << current_range

  result
end
