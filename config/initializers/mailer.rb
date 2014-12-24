ActionMailer::Base.default :from => Proc.new { from_address }

def from_address
  tenant = Tenant.find_by(subdomain: Apartment::Tenant.current)
  "#{tenant.try(:description)} <#{Rails.application.secrets.mail_full_email}>"
end

ActionMailer::Base.default_url_options[:host] = Rails.application.secrets.domain
Rails.application.config.action_mailer.default_url_options ||= {}
Rails.application.config.action_mailer.default_url_options[:host] = Rails.application.secrets.domain

unless Rails.env.test?
  if Rails.application.secrets.aws_access_key.present?
    ActionMailer::Base.delivery_method = :amazon_ses
  else
    ActionMailer::Base.smtp_settings = {
      address:              Rails.application.secrets.mail_server,
      port:                 Rails.application.secrets.mail_port,
      domain:               Rails.application.secrets.mail_domain,
      user_name:            Rails.application.secrets.mail_username,
      password:             Rails.application.secrets.mail_password,
      authentication:       Rails.application.secrets.mail_authentication,
      enable_starttls_auto: (Rails.application.secrets.mail_tls.to_s == 'true')
    }
    ActionMailer::Base.delivery_method = :smtp
  end
end

if Rails.env.development? || Rails.env.naucc?
  class OverrideMailRecipient
    def self.delivering_email(mail)
      mail.body = "DEVELOPMENT-OVERRIDE. Was being sent to #{mail.to} bcc: #{mail.bcc}\n" + mail.body.to_s
      mail.to = Rails.application.secrets.error_emails
      mail.cc = nil
      mail.bcc = nil
    end
  end
  ActionMailer::Base.register_interceptor(OverrideMailRecipient)
end
