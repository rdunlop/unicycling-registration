require 'exception_notification/rails'

require 'exception_notification/sidekiq'

ExceptionNotification.configure do |config|
  # Ignore additional exception types.
  # ActiveRecord::RecordNotFound, AbstractController::ActionNotFound and ActionController::RoutingError are already added.
  config.ignored_exceptions += %w(Errors::TenantNotFound ActionController::BadRequest)

  # Adds a condition to decide when an exception must be ignored or not.
  # The ignore_if method can be invoked multiple times to add extra conditions.
  config.ignore_if do |_exception, _options|
    !Rails.application.secrets.error_emails.present?
  end

  # if we throw an exception while rendering the template,
  # the exception is wrapped in a ActionView::Template::Error
  config.ignore_if do |exception, _options|
    exception.respond_to?(:original_exception) && exception.original_exception.is_a?(Errors::TenantNotFound)
  end

  # Notifiers =================================================================

  # Email notifier sends notifications by email.
  config.add_notifier :email, {
    email_prefix: "[#{Rails.env}][Registration Exception] ",
    sender_address: Rails.application.secrets.mail_full_email,
    exception_recipients: Rails.application.secrets.error_emails
  }

  # Campfire notifier sends notifications to your Campfire room. Requires 'tinder' gem.
  # config.add_notifier :campfire, {
  #   :subdomain => 'my_subdomain',
  #   :token => 'my_token',
  #   :room_name => 'my_room'
  # }

  # HipChat notifier sends notifications to your HipChat room. Requires 'hipchat' gem.
  # config.add_notifier :hipchat, {
  #   :api_token => 'my_token',
  #   :room_name => 'my_room'
  # }

  # Webhook notifier sends notifications over HTTP protocol. Requires 'httparty' gem.
  # config.add_notifier :webhook, {
  #   :url => 'http://example.com:5555/hubot/path',
  #   :http_method => :post
  # }
end
