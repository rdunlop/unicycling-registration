Recaptcha.configure do |config|
  config.public_key  = Rails.application.secrets.recaptcha_public_key
  config.private_key = Rails.application.secrets.recaptcha_private_key
  # Uncomment the following line if you are using a proxy server:
  # config.proxy = 'http://myproxy.com.au:8080'
  # Uncomment if you want to use the newer version of the API,
  # only works for versions >= 0.3.7:
  # config.api_version = 'v2'
end
