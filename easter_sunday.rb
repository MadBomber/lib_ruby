# ~/lib/ruby/easter_sunday.rb
# Give a year, returns the Date of Easter Sunday

def easter_sunday(year)
  # Gauss's Algorithm to calculate Easter Sunday
  a = year % 19
  b = year / 100
  c = year % 100
  d = b / 4
  e = b % 4
  f = (b + 8) / 25
  g = (b - f + 1) / 3
  h = (19 * a + b - d - g + 15) % 30
  i = c / 4
  k = c % 4
  l = (32 + 2 * e + 2 * i - h - k) % 7
  m = (a + 11 * h + 22 * l) / 451
  easter_month = (h + l - 7 * m + 114) / 31  # == 3 for March, or 4 for April
  easter_day = ((h + l - 7 * m + 114) % 31) + 1
  return Date.new(year, easter_month, easter_day)
end
