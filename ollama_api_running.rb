# lib/ruby/ollama_api_running.rb

require 'net/http'
require 'uri'

def ollama_api_running?(url: 'http://localhost:11434')
  uri = URI.parse(url)

  begin
    response = Net::HTTP.get_response(uri)
    response.is_a?(Net::HTTPSuccess)
  rescue StandardError => e
    puts "Error checking Ollama API: #{e.message}"
    false
  end
end
