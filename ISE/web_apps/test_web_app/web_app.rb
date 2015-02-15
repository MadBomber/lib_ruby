#!/usr/bin/env ruby
#####################################################################
###
##  File:  web_app.rb
##  Desc:  generic web application to demonstrate how to receive an IseMessage
##         This program also demonstrates how to announce the availability of a service
#

require 'rubygems'
require 'sinatra'   # web application framework
require 'haml'      # short hand for HTML
#require 'dnssd'     # DNS Service Disicovery
#require 'systemu'
require 'pp'

# NOTE: To receive IseMessage you do not need to subscribe in the web app.
#       The subscription is handled by the WebAppFeeder IseRubyModel.  Its command
#       line parameters specify the URL and the list of IseMessages that are to be
#       sent to the URL.

class WebApp < Sinatra::Application 


set :app_file,    __FILE__
set :environment, :development

#set :root,    File.dirname(__FILE__)
#set :public,  File.dirname(__FILE__) + '/public'
#set :views,   File.dirname(__FILE__) + '/views'
#enable :static

enable :sessions
enable :clean_trace
enable :logging
enable :dump_errors
enable :show_exceptions



$msg_queue = Array.new

get '/' do
  3.times do
    tn = Time.new
    $msg_queue << [tn.to_f, tn]
  end
  haml :index
end

get '/clear' do
  msg_count = $msg_queue.length
  $msg_queue = []
  "The message queue has been cleared of #{msg_count} messages."
end

get '/received' do
  haml :received
end

post '/message' do
  $msg_queue << [Time.now.to_f, 'Unknown', params]
  puts "Received an Unknown Message Type"
  puts params.pretty_inspect
end

post '/message/ThreatWarning' do
  puts "WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW"
  $msg_queue << [Time.now.to_f, 'ThreatWarning', params]
  puts "Received a ThreatWarning Type"
  puts params.pretty_inspect
end

=begin
post '/message/ThreatDetected' do
  puts "DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD"
  $msg_queue << [Time.now.to_f, 'ThreatDetected', params]
  puts "Received a ThreatDetected Type"
  puts params.pretty_inspect
end
=end

post '/message/:msg_name' do |message_name|
  puts "DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD"
  $msg_queue << [Time.now.to_f, message_name, params]
  puts "Received a #{message_name} Type"
  puts params.pretty_inspect
end

####################################
## Announce the web_app as available
=begin
$child_process,report,b = systemu("avahi-publish -s WebApp _http._tcp. 4567 \"Generic WebApp\" &")

pp $child_process
=end

at_exit do
  puts "Killing the WebApp"
  # Process.kill("HUP", $child_process.pid)
end


end

WebApp.run!













