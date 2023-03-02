##############################################
###
##  File: refinements_array.rb
##  Desc: some common refinements on the Array class
#

module Refinements

  refine ::Array do

    # return duplicate entries in an Array
    def duplicates
      self.detect{ |e| self.count(e) > 1 }
    end

  end # refine ::Array do
end # module Refinements
