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

  end # refine String do

end # module Refinements

