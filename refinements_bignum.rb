##############################################
###
##  File: refinements_bignum.rb  
##  Desc: some common refinements on the Integer class (formerly Bignum)
##  Note: Bignum was unified with Fixnum into Integer in Ruby 2.4+
#

module RefinementsBignum

  refine Integer do

    def humanize(comma=',')
      self.to_s.reverse.gsub(/(\d{3})(?=\d)/, "\\1#{comma}").reverse
    end

  end # refine Integer do
    
end # module RefinementsBignum

