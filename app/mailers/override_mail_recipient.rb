class OverrideMailRecipient
  def self.delivering_email(mail)
    mail.body = "DEVELOPMENT-OVERRIDE. Was being sent to #{mail.to} bcc: #{mail.bcc}\n" + mail.body.to_s
    mail.to = Rails.configuration.error_emails
    mail.cc = nil
    mail.bcc = nil
  end
end
