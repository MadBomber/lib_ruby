# Originally developed as part of a Rails app
# http://blog.bigbinary.com/2015/01/12/phone-verification-using-twilio.html

class PhoneVerificationService
  attr_reader :user

  def initialize(options)
    @user = User.find(options[:user_id])
  end

  def process
    send_sms
  end

  private

  def from
    # Add your twilio phone number (programmable phone number)
    Settings.twilio_number_for_app
  end

  def to
    # +1 is a country code for USA
    "+1#{user.phone_number}"
  end

  def body
    "Please reply with this code '#{user.phone_verification_code}' to
    verify your phone number"
  end

  def twilio_client
    # Pass your twilio account sid and auth token
    @twilio ||= Twilio::REST::Client.new(Settings.twilio_account_sid,
                                         Settings.twilio_auth_token)
  end

  def send_sms
    Rails.logger.info "SMS: From: #{from} To: #{to} Body: \"#{body}\""

    twilio_client.account.messages.create(
      from: from,
      to: to,
      body: body
    )
  end

end # class PhoneVerificationService

