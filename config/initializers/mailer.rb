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

Rails.application.configure do
  if Rails.env.development? || Rails.env.naucc?
    config.action_mailer.interceptors = %w[OverrideMailRecipient]
  end
end

Rails.application.configure do
  if Rails.env.stage?
    config.action_mailer.interceptors = %w[StageEmailInterceptor]
  end
end
