#####################################################################
###
##  File:  datetime_mods.rb
##  Desc:  Modifications to the Date, DateTime and Time classes.
#

module ModsDataTimeEtc
  def before?(thing) (self <= thing); end
  def after?(thing)  (self >= thing); end
end

class Date
  include ModsDateTimeEtc
  def to_unix() self.to_time.to_i; end
end

class DateTime
  include ModsDateTimeEtc
  def to_unix() self.to_time.to_i; end
end

class Time
  include ModsDateTimeEtc
  def to_unix() self.to_i; end
end
