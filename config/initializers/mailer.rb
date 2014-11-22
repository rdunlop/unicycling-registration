ActionMailer::Base.smtp_settings = {
    :address              => Rails.application.secrets.mail_server,
    :port                 => Rails.application.secrets.mail_port,
    :domain               => Rails.application.secrets.mail_domain,
    :user_name            => Rails.application.secrets.mail_username,
    :password             => Rails.application.secrets.mail_password,
    :authentication       => "plain",
    :enable_starttls_auto => (Rails.application.secrets.mail_tls.nil? ? true : Rails.application.secrets.mail_tls)
}
ActionMailer::Base.default :from => Rails.application.secrets.mail_full_email

ActionMailer::Base.default_url_options[:host] = Rails.application.secrets.domain

if Rails.env.development? or Rails.env.naucc?
  class OverrideMailRecipient
    def self.delivering_email(mail)
      mail.body = "DEVELOPMENT-OVERRIDE. Was being sent to #{mail.to} bcc: #{mail.bcc}\n" + mail.body.to_s
      mail.to = Rails.application.secrets.error_email
      mail.cc = nil
      mail.bcc = nil
    end
  end
  ActionMailer::Base.register_interceptor(OverrideMailRecipient)
end
