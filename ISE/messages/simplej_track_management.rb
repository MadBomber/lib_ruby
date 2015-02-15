###############################################
###
##   File:   SimpleJTrackManagement.rb
##   Desc:   Simple J wrapped TrackManagement Message
##
#

require 'SimpleJMessage'
require 'TrackManagement'

class SimpleJTrackManagement < SimpleJMessage
  def initialize
    super(TrackManagement)
    desc "Simple J wrapped TrackManagement Message"
 end
end
