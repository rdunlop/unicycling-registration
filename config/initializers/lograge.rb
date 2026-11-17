Rails.application.configure do
  config.lograge.enabled = true
  config.lograge.formatter = Lograge::Formatters::Json.new

  # Request context for investigating who called what. The client IP comes from
  # remote_ip, which reads X-Forwarded-For set by the ALB. Params and bodies are
  # never logged here; path_with_query uses filtered_path so filtered values
  # (such as reset_password_token) stay out of the log.
  config.lograge.custom_payload do |controller|
    request = controller.request

    {
      ip: request.remote_ip,
      forwarded_for: request.get_header('HTTP_X_FORWARDED_FOR'),
      user_agent: request.user_agent.to_s.truncate(200),
      referer: request.referer.to_s.truncate(200).presence,
      host: request.host,
      path_with_query: request.filtered_path,
      user_id: controller.try(:current_user)&.id
    }
  end

  config.lograge.custom_options = lambda do |event|
    {
      tenant: Apartment::Tenant.current,
      request_id: event.payload[:headers]&.[]('X-Request-Id')
    }
  end
end
