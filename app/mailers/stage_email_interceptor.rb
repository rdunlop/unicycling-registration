# per http://thepugautomatic.com/2012/08/abort-mail-delivery-with-rails-3-interceptors/
class StageEmailInterceptor
  attr_accessor :message

  def initialize(message)
    @message = message
  end

  def self.delivering_email(message)
    new(message).process
  end

  def process
    prefix_subject

    original_addresses = get_addresses

    message.to = Rails.application.secrets.server_admin_email
    message.cc = nil
    message.bcc = nil

    message.body = "Interceptor prevented sending mail with addresses: #{original_addresses}.\n\n#{message.body}"
  end

  def get_addresses
    prefix = "to: #{message.to}\n"
    prefix += "cc: #{message.cc}\n"
    prefix += "bcc: #{message.bcc}\n"
    prefix
  end

  def prefix_subject
    message.subject = "[#{Apartment::Tenant.current} STAGING] #{message.subject}"
  end
end
