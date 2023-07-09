# ~/lib/ruby/next_dow.rb

require 'date'

# Finds the next occurrence of a given day of the week.
#
# @param dow [Symbol] The day of the week to find (e.g., :monday, :tuesday).
# @param date [Date] The starting date (default: today's date).
# @return [Date] The date of the next occurrence of the given day of the week.
def next_dow(dow, date = Date.today)
  target_day = Date::DAYNAMES.index(dow.to_s.capitalize)
  
  raise ArgumentError, "Bad DOW: #{dow}"         if target_day.nil? 
  raose ArgumentError, "Bad DATE: #{date.class}" unless date.is_a? Date

  result = date.next_day
  result = result.next_day until result.wday == target_day

  result
end

