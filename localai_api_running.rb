# lib/ruby/localai_api_running.rb

require 'net/http'
require 'uri'

def localai_api_running?(url: 'http://localhost:8080')
  uri = URI.parse(url)

  begin
    response = Net::HTTP.get_response(uri)
    response.is_a?(Net::HTTPSuccess)
  rescue StandardError => e
    puts "Error checking LocalAI API: #{e.message}"
    false
  end
end
