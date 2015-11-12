# variable_name_of.rb
# Takes a string and an optional convention and returns a
# string suitable as a variable name in the convention.
# The support conventions are:
#   :snake_case (default)
#   :tall_snake_case (ex: tall-snake-case)
#   :CamelCase
#   :lowerCamelCase
#  Any text between parans is removed.
#  Any non-alphanumberic is removed.

def variable_name_of(a_string, convention = :snake_case)
  unless String == a_string.class
    unless a_string.respond_to?(:to_s)
      raise ArgumentError, "Expected a string; got #{a_string.class}"
    else
      a_string = a_string.to_s
    end
  end
  if a_string.include?('(')
  	p_start = a_string.index('(')
  	p_end   = a_string.index(')')
  	a_string[p_start..p_end] = ''
  end
  parts = a_string.downcase.gsub(/[^0-9a-z ]/, ' ').squeeze(' ').split
  case convention
    when :lowerCamelCase 
      parts.size.times do |x|
      	next unless x>0
      	parts[x][0] = parts[x][0].upcase
      end
      variable_name = parts.join
    when :CamelCase 
      parts.size.times do |x|
      	parts[x][0] = parts[x][0].upcase
      end
      variable_name = parts.join    
    when :snake_case 
      variable_name = parts.join('_')
    when :tall_snake_case
      variable_name = parts.join('-')
    else
      raise ArgumentError, "Invalid Convention: #{convention}"
  end

  return variable_name
end # def variable_name_of(a_string, convention
