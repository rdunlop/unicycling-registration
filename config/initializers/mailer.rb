ActionMailer::Base.default from: proc { from_address }

def from_address
  name = EventConfiguration.singleton.short_name
  "#{name} <#{Rails.configuration.mail_full_email}>"
end

ActionMailer::Base.default_url_options[:host] = Rails.configuration.domain
Rails.application.config.action_mailer.default_url_options ||= {}
Rails.application.config.action_mailer.default_url_options[:host] = Rails.configuration.domain

unless Rails.env.test?
  if Rails.configuration.aws_access_key.present?
    ActionMailer::Base.delivery_method = :ses
  end
end

if Rails.env.development? || Rails.env.naucc?
  class OverrideMailRecipient
    def self.delivering_email(mail)
      mail.body = "DEVELOPMENT-OVERRIDE. Was being sent to #{mail.to} bcc: #{mail.bcc}\n" + mail.body.to_s
      mail.to = Rails.configuration.error_emails
      mail.cc = nil
      mail.bcc = nil
    end
  end
  ActionMailer::Base.register_interceptor(OverrideMailRecipient)
end

if Rails.env.stage?
  ActionMailer::Base.register_interceptor(StageEmailInterceptor)
end

# force the mailer to always queue on the 'default' queue
class ActionMailer::DeliveryJob
  queue_as :default
end
