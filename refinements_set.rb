##############################################
###
##  File: refinements_set.rb
##  Desc: some common refinements on the Set class
#

module Refinements

  refine ::Set do

    # NOTE: give two sets s1 and s2 tha it is possible
    #       for s1.like?(s2) and NOT s2.like?(s1) depending
    #       on the relative size of each set.
    def like?(a_set, threshold=0.75)
      likeness(a_set) > threshold
    end

    # NOTE: that the size of a_set governs the degree of likeness
    #       between any two sets.  The likeness of one set to
    #       another is dependant upon the size of the intersection
    #       to the size of the parameter set.
    def likeness(a_set)
      self & a_set).size.to_f / a_set.size.to_f
    end

  end # refine ::Set do
end # module Refinements
