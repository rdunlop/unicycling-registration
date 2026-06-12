Rails.application.configure do
  config.lograge.enabled = true
  config.lograge.formatter = Lograge::Formatters::Json.new
  config.lograge.custom_options = lambda do |event|
    {
      tenant: Apartment::Tenant.current,
      request_id: event.payload[:headers]&.[]("X-Request-Id")
    }
  end
end
