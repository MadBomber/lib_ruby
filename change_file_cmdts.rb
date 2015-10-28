require 'time'
require 'date'

# Change the creation and modification date/time stampe
# of a file.
# a_string is path to the file
# a_datetime is a DateTime object to which the creation/modification time should be set

def change_file_cmdts(a_string, a_datetime)
  tt = Time.parse a_datetime.to_s
  File.utime(tt,tt,a_string)
end
