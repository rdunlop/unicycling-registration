require "sidekiq/middleware/i18n"

unless Rails.env.test?
  Sidekiq.configure_server do |config|
    config.redis = Redis.sidekiq_configuration
  end

  Sidekiq.configure_client do |config|
    config.redis = Redis.sidekiq_configuration
  end
end
