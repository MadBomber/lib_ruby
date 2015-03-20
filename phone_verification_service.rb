# Originally developed as part of a Rails app
# http://blog.bigbinary.com/2015/03/18/voice-based-phone-verification-using-twilio.html

class PhoneVerificationService
  attr_reader :user, :verification_through

  VERIFICATION_THROUGH_SMS  = :sms
  VERIFICATION_THROUGH_CALL = :call

  def initialize options
    @user                 = User.find(options[:user_id])
    @verification_through = options[:verification_through] || VERIFICATION_THROUGH_SMS
  end

  def process
    if verification_through == VERIFICATION_THROUGH_SMS
      perform_sms_verification
    else
      make_call
    end
  end

  private

  def from
    #phone number given by twilio
    Settings.twilio_number_for_app
  end

  def to
    # +1 is a country code for USA
    "+1#{user.phone_number}"
  end

  def body
    "Please reply with this code '#{user.phone_verification_code}' to verify your phone number"
  end

  def send_sms
    Rails.logger.info "SMS: From: #{from} To: #{to} Body: \"#{body}\""

    twilio_client.account.messages.create(
      from: from,
      to: to,
      body: body
    )
  end

  def make_call
    Rails.logger.info "Call: From: #{from} To: #{to}"

    twilio_client.account.calls.create(
      from: from,
      to: to,
      url: callback_url
    )
  end

  def perform_sms_verification
    begin
      send_sms
    rescue Twilio::REST::RequestError => e
      return make_call if e.message.include?('is not a mobile number')
      raise e.message
    end
  end

  def callback_url
    Rails.application.routes.url_helpers
      .phone_verifications_voice_url(host: Settings.app_host,
                                     verification_code: user.phone_verification_code)
  end

  def twilio_client
    @twilio ||= Twilio::REST::Client.new(Settings.twilio_account_sid,
                                         Settings.twilio_auth_token)
  end

end # class PhoneVerificationService
