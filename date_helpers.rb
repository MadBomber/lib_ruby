
class Date
  def next_sunday_or_eoy
    new_date = self + (7 - self.wday)
    new_date.year == self.year ? new_date : self.class.new(year,month,31)
  end
end
