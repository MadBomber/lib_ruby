# internet_connected.rb

require 'net/ping'

def internet_connected?
  Net::Ping::External.new('google.com').ping?
end
