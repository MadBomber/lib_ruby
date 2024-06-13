# For Strings that have the pattern:
#   <last name>,<first name> <middle name>
# If no command, everythings goes into last_name
# middle name is optional.
#
# Returns Hash containing the name parts
#
def extract_name_parts(full_name)
  last_name, remainder = full_name.split(',', 2).map(&:strip)
  first_name, middle_name = (remainder || '').split(' ', 2)
  
  {
    last_name:   last_name,
    first_name:  first_name  || '',
    middle_name: middle_name || ''
  }
end
