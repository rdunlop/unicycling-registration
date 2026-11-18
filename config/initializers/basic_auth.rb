# frozen_string_literal: true

# Optional HTTP Basic Auth gate for the whole site (used on staging).
#
# Enabled only when BOTH BASIC_AUTH_USERNAME and BASIC_AUTH_PASSWORD are set.
# With either one missing, the app runs with no extra gate.
#
# Inserted at position 0 so it runs before Rack::Attack, sessions and routing.

require 'rack/auth/basic'

basic_auth_username = ENV.fetch('BASIC_AUTH_USERNAME', nil)
basic_auth_password = ENV.fetch('BASIC_AUTH_PASSWORD', nil)

# Same as Rack::Auth::Basic, but lets the ELB health check through without
# credentials. The ALB target group must check this path, not "/" (which would
# return 401 behind the gate).
class BasicAuthExceptHealthcheck < Rack::Auth::Basic
  def call(env)
    return @app.call(env) if env['PATH_INFO'] == '/healthcheck'

    super
  end
end

if basic_auth_username.present? && basic_auth_password.present?
  Rails.application.config.middleware.insert_before 0, BasicAuthExceptHealthcheck, 'Restricted' do |username, password|
    ActiveSupport::SecurityUtils.secure_compare(username, basic_auth_username) &
      ActiveSupport::SecurityUtils.secure_compare(password, basic_auth_password)
  end
end
