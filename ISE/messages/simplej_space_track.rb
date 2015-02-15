###############################################
###
##   File:   SimpleJSpaceTrack.rb
##   Desc:   Simple J wrapped SpaceTrack Message
##
#

require 'SimpleJMessage'
require 'SpaceTrack'

class SimpleJSpaceTrack < SimpleJMessage
  def initialize
    super(SpaceTrack)
    desc "Simple J wrapped SpaceTrack Message"
 end
end
