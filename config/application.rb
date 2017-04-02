require_relative 'boot'

require 'rails/all'
require File.expand_path('../../config/initializers/redis', __FILE__)

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
    config.i18n.available_locales = [:en, :fr, :de, :hu, :es, :ja]

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
  end
end
