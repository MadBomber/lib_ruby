###############################################
###
##   File:   SimpleJAirTrack.rb
##   Desc:   Simple J wrapped AirTrack Message
##
#

require 'SimpleJMessage'
require 'AirTrack'

class SimpleJAirTrack < SimpleJMessage
  def initialize
    super(AirTrack)
    desc "Simple J wrapped AirTrack Message"
  end
end
