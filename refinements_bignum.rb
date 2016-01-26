##############################################
###
##  File: refinements_bignum.rb
##  Desc: some common refinements on the Bignum class
#

module Refinements

  refine Bignum do

    def humanize(comma=',')
      self.to_s.reverse.gsub(/(\d{3})(?=\d)/, "\\1#{comma}").reverse
    end

  end # refine Bignum do
    
end # module Refinements

