# frozen_string_literal: true

Hcaptcha.configure do |config|
  # Disable hcaptcha if it is not configured
  if Rails.configuration.hcaptcha_site_key.nil? || Rails.configuration.hcaptcha_secret.nil?
    config.skip_verify_env << Rails.env.to_s
    config.site_key = "FAKE_SITE_KEY"
    config.secret_key = "FAKE_SECRET_KEY"
  else
    config.site_key = Rails.configuration.hcaptcha_site_key
    config.secret_key = Rails.configuration.hcaptcha_secret
  end
end
