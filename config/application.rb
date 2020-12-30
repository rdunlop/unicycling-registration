require_relative 'boot'

require 'rails/all'
require File.expand_path('../config/initializers/redis', __dir__)

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Workspace
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de
    config.i18n.enforce_available_locales = true
    config.i18n.default_locale = :en
    config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.{rb,yml}').to_s]

    # These are the default list of available languages.
    # Note: this is overwritten in application_controller.rb once an EventConfiguration is loaded.
    config.i18n.available_locales = %i[en fr de hu es ja ko it da nl]

    config.encoding = "utf-8"

    # In order for Devise to send e-mail asynchronously, we have to
    # configure an ActiveJob queue Adapter
    config.active_job.queue_adapter = :sidekiq

    config.action_dispatch.rescue_responses['Errors::TenantNotFound'] = :not_found

    config.generators do |g|
      g.helper_specs false
      g.routing_specs false
      g.helper false
    end

    config.tinymce.install = :compile

    config.iuf_membership_url = ENV["IUF_MEMBERSHIP_URL"]
    config.iuf_membership_api_url = ENV["IUF_MEMBERSHIP_API_URL"]
    config.usa_wildapricot_account_id = ENV["USA_WILDAPRICOT_ACCOUNT_ID"]
    config.usa_wildapricot_api_key = ENV["USA_WILDAPRICOT_API_KEY"]

    config.domain = ENV["DOMAIN"]
    # Forces SSL connections
    config.ssl_enabled = ENV["SSL_ENABLED"] == "true"

    config.secret_key_base = ENV.fetch("SECRET_KEY_BASE")

    # For use by S3, SES, and storage of SSL Cert data
    config.aws_bucket = ENV["AWS_BUCKET"]
    config.aws_access_key = ENV["AWS_ACCESS_KEY"]
    config.aws_secret_access_key = ENV["AWS_SECRET_ACCESS_KEY"]
    config.aws_region = ENV["AWS_REGION"]


    config.redis_host = ENV["REDIS_HOST"]
    config.redis_port = ENV["REDIS_PORT"]
    # db: 0 # if you have sidekiq for different rails-databases running against the same redis, increment this for each
    config.redis_db = ENV["REDIS_DB"]

    # where to send users who want to do translations of the registration system
    config.translation_website_url = ENV["TRANSLATION_WEBSITE_URL"]
    # subdomain to match to indicate that we are on the "translation" subdomain.
    # all users on this subdomain are ALWAYS "translator" users.
    # TODO: this also causes emails to be sent whenever someone applies translations through Tolk
    config.translations_subdomain = ENV["TRANSLATIONS_SUBDOMAIN"]

    # If you want to allow user accounts to be created WITHOUT requiring e-mail
    # confirmation, set the following variable, or "Authorize the laptop":
    config.mail_skip_confirmation = ENV["mail_skip_confirmation"] == "true"

    # NOTE: In development, ALL E-MAIL will be sent to the ERROR_EMAIL address,
    #  but in production it will flow as expected.
    config.error_emails = ENV.fetch("ERROR_EMAILS", "").split(",")

    # Token for sending exception reports to rollbar for further investigation
    config.rollbar_access_token = ENV["ROLLBAR_ACCESS_TOKEN"]

    # this e-mail will receive a CC of every payment confirmation sent
    config.payment_notice_email = ENV["PAYMENT_NOTICE_EMAIL"]

    # This e-mail will receive informational e-mails about the server
    config.server_admin_email = ENV["SERVER_ADMIN_EMAIL"]

    # code used to create new convention instances
    config.instance_creation_code = ENV["INSTANCE_CREATION_CODE"]

    config.recaptcha_public_key = ENV["RECAPTCHA_PUBLIC_KEY"]
    config.recaptcha_private_key = ENV["RECAPTCHA_PRIVATE_KEY"]




  end
end
