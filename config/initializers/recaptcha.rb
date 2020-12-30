Recaptcha.configure do |config|
  config.site_key = Rails.configuration.recaptcha_public_key
  config.secret_key = Rails.configuration.recaptcha_private_key
end
