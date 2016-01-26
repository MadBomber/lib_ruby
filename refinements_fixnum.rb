##############################################
###
##  File: refinements_fixnum.rb
##  Desc: some common refinements on the Fixnum class
#

module Refinements

  refine ::Fixnum do

    def humanize(comma=',')
      self.to_s.reverse.gsub(/(\d{3})(?=\d)/, "\\1#{comma}").reverse
    end

  end # refine Fixnum do
    
end # module Refinements

