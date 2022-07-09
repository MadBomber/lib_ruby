# lib/dst_dates.rb

=begin
  Daylight Savings Time (DST) is observed in about 70 countries; but,
  not at the same time or in the same way.   In healthmatters we
  have sveral process that deal with scheduling things around the clock
  in various timezones and locations.

  Without taking DST time changes into account we end up with scheduling
  some things in a way that has to be hand edited later.  Hopefully
  using this module we can alert the user to those days in which
  a time change will occur.
=end


module DstDates

  # Returns am Array of Arrays for the Time to spring forward
  # and the Time to fall back in an implementation of daylight
  # savings time (DST)
  #
  # The inner arrays is the datetime, and the timezone abbrevation
  #
  # Example Usage for current timezone and current year:
  #   include DstDates
  #   spring_forward, fall_back = dst_times
  #
  # Typical Usage would be to include the module in a model or controller
  #
  # Returns this kind of Array:
  #
  # [
  #   [2022-03-13 02:00:00 UTC, :EDT],  # Spring Forward: Time object, Symbol
  #   [2022-11-06 02:00:00 UTC, :EST]   # Fall Back:      To,e object, Symbol
  # ]
  #
  # NOTICE that the Time object is in UTC ... However, the date and time
  # values are correct in any timezone.
  #
  def dst_times(tz: ENV['TZ'], year: Time.now.year)
    result  = TZInfo::Timezone.get(tz)
                .transitions_up_to(
                  Time.utc(year+1, 1, 1),
                  Time.utc(year, 1, 1)
                ).map{ |t|
                  [
                    t.local_end_at.to_time,
                    t.offset.abbreviation
                  ]
                }

    return result
  end


  # worldwide, the time change is symetrical i.e. happens
  # at the same hour both forward and backward in the same timezone.
  # That hour varies from one country to another.  For example in
  # North America the hour is 2.  In Europe the hour is 1.
  #
  def dst_change_hour(tz: ENV['TZ'], year: Time.now.year)
    dst_spring_forward_time.hour
  end


  # Returns the spring_forward Time object
  def dst_spring_forward_time(tz: ENV['TZ'], year: Time.now.year)
    return dst_dates(tz: tz, year: year).first[0]
  end


  # Returns the fall_back Time object
  def dst_fall_back_time(tz: ENV['TZ'], year: Time.now.year)
    return dst_dates(tz: tz, year: year).last[0]
  end


  # Returns a boolean which tells whether a specific day is a time change day
  def dst_time_change_on(date:, tz: ENV['TZ'], year: Time.now.year)
    the_dates = dst_dates(tz: tz, year: date.year).map{|t| t.first.to_date}

    return the_dates.include? date.to_date
  end


  # Answers the question is today a time change day?
  def dst_time_change_today?(tz: ENV['TZ'], year: Time.now.year)
    dst_time_change_on date: Time.zone.today, tz: tz, year: year
  end


  # Answers the question is tomorrow a time change day?
  def dst_time_change_tomorrow?(tz: ENV['TZ'], year: Time.now.year)
    dst_time_change_on date: Time.zone.tomorrow, tz: tz, year: year
  end
end # module DstDates
