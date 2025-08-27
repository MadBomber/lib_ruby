##############################################
###
##  File: refinements_integer.rb
##  Desc: some common refinements on the Integer class
#

module Refinements

  refine ::Integer do

    def humanize(comma=',')
      self.to_s.reverse.gsub(/(\d{3})(?=\d)/, "\\1#{comma}").reverse
    end

  end # refine Integer do

end # module Refinements

