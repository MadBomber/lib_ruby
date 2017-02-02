# lib/ruby/truth_or_consequences.rb

# Sets Kernel-level constant as object TrueClass and/or FalseClass
# from boolean-like system environment variables.

# The system environment variable name/key must be all uppercase.
# The param 'a_string' can be any case.

def self.truth_or_consequences(a_string)
  a_string.upcase!
  result = (  !ENV[a_string].nil? &&
              %w[true yes yep y sure].include?(ENV[a_string].downcase)) ? true : false
  Kernel.const_set(a_string, result)
end
