# ~/lib/ruby/fetch_ollama_models.rb

require 'net/http'
require 'json'
require 'uri'

# Returns an Array of Hash entries describing the models
# that are currently available on the localhost.
# If there is a problem, then value nil is returned and
# an error message is written to STDOUT
#
def fetch_ollama_models
  # Default Ollama server URL
  uri = URI('http://localhost:11434/api/tags')
  
  begin
    response = Net::HTTP.get_response(uri)
    
    if response.is_a?(Net::HTTPSuccess)
      JSON.parse(response.body)
    else
      puts "Error: Failed to fetch models (HTTP #{response.code})"
      nil
    end
    
  rescue Errno::ECONNREFUSED
    puts "Error: Could not connect to Ollama server. Is it running at #{uri}?"
    nil
  rescue JSON::ParserError
    puts "Error: Received invalid JSON response"
    nil
  rescue StandardError => e
    puts "Error: #{e.message}"
    nil
  end


