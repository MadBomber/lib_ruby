# date_transformer.rb
# Takes a String or Date type and transforms it from
# one format to another.  For example it can convert
# "06/03/1953" to "1953-06-03"
#
# The options to: and from: are used by the
# strftime and strptime utilities respectifully.
# See their documentation for details.
#
# The returned value is a string.

require 'date'

def date_transformer(a_date_or_string, options={})
  formats = {to: '%Y-%m-%d', from: '%m/%d/%Y'}.merge(options)
  if String == a_date_or_string.class
  	return(nil) if a_date_or_string.empty?
  	a_date = Date.strptime(a_date_or_string, formats[:from])
  elsif a_date_or_string.nil?
    return(nil)
  else
  	a_date = a_date_or_string  
  end

  a_date.strftime(formats[:to])
end # def date_transformer(a_date_or_string, options={})
