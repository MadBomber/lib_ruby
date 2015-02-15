#!/usr/bin/env ruby
#####################################################################


require 'rubygems'
require 'rest_client'     # full RESTful interaction with a web site
#require 'dnssd'           # DNS Service Discovery
require 'systemu'
require 'ThreatDetected'  # An IseMessage used by the AADSE project
require 'ThreatWarning'   # An IseMessage used by the AADSE project
require 'pp'

  $frame_count = 0


#DNSSD.browse '_http._tcp.' do |r|
#	pp r
#	puts "-"*15
#end

=begin
a,report,c = systemu("avahi-browse -r -t -f -a -p")

puts "##################"
things = report.split("\n")

x = 0
things.each do |t|
   
  if t[0,1] == '='
    if t.include? 'WebApp'
      things[x] = t.split(';')
    else
      things[x] = nil
    end
  else
    things[x] = nil
  end
  x += 1
end

things.compact!

abort "No WebApps were found.  Abort program." if things.empty?

puts "Number of WebApps found: #{things.length} using only the first one:"

web_app = things[0]

ip_address  = web_app[7]
port        = web_app[8]
desc        = web_app[9].chomp
=end

ip_address  = "138.209.52.137"
port        = 4567
desc        = "hard coded ip:port"

puts "WebApp -=> #{ip_address}:#{port} #{desc}"




#############################################
## This setup emulates an IseMessage that
## has been received by an IseModel within
## its call back handler.  At this point the
## message has been fully unpacked.

td = ThreatDetected.new
td.threat_label_  = "WB_001"
td.time_          = Time.now.to_f
td.radar_label_   = "BP_001"

tw = ThreatWarning.new

tw.radar_label_         = "BP_001"
tw.threat_label_        = "WBmale_001"
tw.time_                = Time.now.to_f
tw.defended_area_label_ = "Texas"
tw.impact_time_         = 288
tw.launch_area_label_   = "Mexico"

######################################################
## Define the web applications receiving controller for IseMessage
## post events.

url       = "http://#{ip_address}:#{port}/message"
username  = 'aadse'
password  = username

web_app = RestClient::Resource.new(url, username, password)


## Emulate the IseModel receiving lots of messages and pass them on to the web application
50.times do |x|

  $frame_count += 1

  a_message = 1 == rand(2) ? tw : td  ## emulate a message coming from different call back handlers
  
  a_message.time_ = Time.now.to_f     ## jsut a test thing to vary the data

  web_app[a_message.class.to_s].post( a_message.to_h.merge( {"run_id_" => 13, "frame_count_" => $frame_count} ) )  # <=- this is it, one line sends the message content to the web app

end






