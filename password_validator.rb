# lib/ruby/password_validator.rb
#
# See: https://gizmodo.com/the-guy-who-invented-those-annoying-password-rules-now-1797643987
# See: https://resources.infosecinstitute.com/password-security-complexity-vs-length/
#
# The engineer who first came up the password complexity rules
# back in the 1980s has since disavowed them.  Bill Burr a manager
# at NIST who wrote the security guidelines in 2003 also regrets it.
#
# The bottom line: the longer the password (lets call it passphrase)
# the better.  The use of pass phrases of six or more words with a total
# length greater than 24 characters is more secure.
#
# A password validation class
class PasswordValidator < ActiveModel::Validator
  # For Validations
  ALPHA_NUMERICS=/[0-9A-Za-z,.]/
  DIGITS=/\d/
  LC_LETTERS=/[a-z]/
  SPECIAL_CHARS=/[\$\^\*~!@#%&]/
  UC_LETTERS=/[A-Z]/
  MINIMUM_PASSWORD_LENGTH = 24    # The longer the better

  def validate(record)
    @password = record.password
    unless password_complexity
      record.errors.add :password, "must be at least 12 characters long, must include at least one lowercase letter, " \
        "one uppercase letter, one digit and one special character from the " \
        "following: ~!@#$%^&*"
    end
  end


  def has_uppercase_letters?
    @password.match(UC_LETTERS) ? true : false
  end

  def has_digits?
    @password.match(DIGITS) ? true : false
    end

  def has_special_chars?
    @password.match(SPECIAL_CHARS) ? true : false
  end

  def has_downcase_letters?
    @password.match(LC_LETTERS) ? true : false
  end

  def has_only_permitted_characters?
    working_str = @password.dup

    special_chars = working_str.scan(SPECIAL_CHARS)
    special_chars.each do |x|
      working_str.gsub!("#{x}", '')
    end

    working_str.gsub!(ALPHA_NUMERICS, '')

    working_str.length == 0
  end

  def has_minimum_length?
    @password.length >= MINIMUM_PASSWORD_LENGTH ? true : false
  end


  ##
  #   password-related
  ##


  def password_complexity
    @password.present?        &&
    has_minimum_length?       &&
    has_uppercase_letters?    &&
    has_digits?               &&
    has_special_chars?        &&
    has_downcase_letters?     &&
    has_only_permitted_characters?
  end

end # class PasswordValidator < ActiveModel::Validator

__END__

In the User model - or whatever - do something like this:

  validates_with PasswordValidator, if: :password_required?
