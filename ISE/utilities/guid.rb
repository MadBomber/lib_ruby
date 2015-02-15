#####################################################################
###
##  File: guid.rb
##  Desc: Wrapper around UUIDTools::UUID.random_create

require 'uuidtools'

class Guid
  attr_accessor :myguid

  def initialize
    @myguid = UUIDTools::UUID.random_create
  end
  
  def to_s
    return @myguid.to_s
  end
end

