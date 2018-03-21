##############################################
###
##  File: refinements_hash.rb
##  Desc: some common refinements on the Hash class
#
require 'set'

module Refinements

  refine ::Hash do

    # searchs a 2-level deep hash looking for entrys (keys) whose sub-key and value
    # are equal to (==) the values given.  If target value is an Array uses
    # Set#subset? to determine equality.
    def where(options={})
      return self if options.empty?  ||  options.class != Hash
      self.select {|key, value|
        result = true
        options.each_pair do |field, field_value|
          if Array == value[field].class
            result &&= Array(field_value).to_set.subset?(value[field].to_set)
          else
            result &&= value[field] == field_value
          end
        end
        result
      }
    end # def where(options)

  end # refine ::Hash do
end # module Refinements
