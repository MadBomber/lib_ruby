require 'json'
require 'open-uri'

# Returns a hash containing user location based upon IP address
def user_location
  return JSON.parse open("http://freegeoip.net/json").read
end

__END__

The hash looks like this:

{
              "ip" => "173.217.8.179",
    "country_code" => "US",
    "country_name" => "United States",
     "region_code" => "LA",
     "region_name" => "Louisiana",
            "city" => "Bossier City",
        "zip_code" => "71112",
       "time_zone" => "America/Chicago",
        "latitude" => 32.4525,
       "longitude" => -93.6365,
      "metro_code" => 612
}
