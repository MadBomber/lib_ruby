# lib/ruby/extract_name_from_email.rb
# Extracts the domain name and the user name from eMails that have the pattern
#     first,i.last@domain
#
# The middle initial is optional.  If present it must be only one character
# The first and last names can only have letters.
#
# Returns:  nil if email does not match pattern
#           [first, last, domain] for validly formatted email address
def extract_name_from_email_address(email_address)
  m_data = /^([a-z]+)\.?[a-z]?\.([a-z]+)@([a-z0-9\.\-]+)$/i.match(email_address)

  m_data.nil? ? nil : m_data.to_a
end
