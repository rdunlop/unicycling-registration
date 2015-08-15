require File.expand_path('../boot', __FILE__)

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
    config.autoload_paths += %W(#{config.root}/lib #{config.root}/lib/judge_points_calculators #{config.root}/lib/comparable_result_calculators #{config.root}/lib/distance_attempt_managers)

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

    # Do not swallow errors in after_commit/after_rollback callbacks.
    config.active_record.raise_in_transactional_callbacks = true

    config.action_dispatch.rescue_responses.merge!(
      'Errors::TenantNotFound' => :not_found
    )

    config.active_job.queue_adapter = :sidekiq

    config.generators do |g|
      g.helper_specs false
      g.routing_specs false
      g.helper false
    end
  end
end
