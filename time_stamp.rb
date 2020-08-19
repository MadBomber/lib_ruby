# lib/ruby/time_stamp.rb

module TimeStamp
  def self.now(format="%F %r %Z %z")
    Time.now.strftime(format)
  end
end
