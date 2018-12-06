# lub/ruby/checked_url.rb
# See: https://medium.com/@wintermeyer/check-and-update-a-url-with-ruby-120e6ba73e4f
#
# Returns nil if the url is invalid - not preset
# returns a string of the url fully formed, followed to final actual endpoint
#
# gem install curb - uses the libcurl library

require 'curb'

def checked_url(url)
  begin
    result = Curl::Easy.perform(url) do |curl|
      curl.head = true
      curl.follow_location = true
      curl.timeout = 3
    end
    result.last_effective_url
  rescue
    nil
  end
end

__END__

From IRB
>> checked_url 'nyt.com' #=> "https://www.nytimes.com/"
