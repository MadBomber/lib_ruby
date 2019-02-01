##############################################
###
##  File: refinements_string.rb
##  Desc: some common refinements on the String class
#

module Refinements

  refine ::String do

    # return only the digits 0123456789 found in a string as a string.
    # Useful to squeezing out junk in phone numbers and SSN data objects
    def to_digits
      self.gsub(/\D/,'')
    end

    # treats the string as a binary buffer.  Returns a new
    # string (suitable for printing) of the hexidecimal vaules of the buffer
    def as_hex
      self.bytes.map { |byte| sprintf('%02x', byte) }.join(' ')
    end
  end # refine String do

end # module Refinements

