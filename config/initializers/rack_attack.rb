# Rate limits for abusive clients (see the Rack::Attack README for the DSL).
#
# Counters are kept in REDIS_URL (the shared ElastiCache instance) when it is
# set, so every ECS task shares one count. Without it, Rack::Attack uses the
# default cache store, which is per process and is only suitable for local dev.
#
# Per-IP limits are set well above normal use, because many people can share
# one address (venue wifi, carrier NAT). Routes are scoped under an optional
# locale (/en/users/password, /da/users/sign_in), so paths allow that prefix.
#
# Throttled requests are logged by the subscriber at the bottom of this file.

require 'rack/attack'

if ENV['REDIS_URL'].present?
  Rack::Attack.cache.store = ActiveSupport::Cache::RedisCacheStore.new(
    url: ENV['REDIS_URL'],
    namespace: 'rack_attack'
  )
end

# Off in test by default, so ordinary request specs are not throttled. Specs
# that test limits turn it on explicitly.
Rack::Attack.enabled = !Rails.env.test?

LOCALE_PREFIX = '(?:/(?:en|fr|de|hu|es|ja|ko|it|da|nl))?'.freeze

RACK_ATTACK_PATH = lambda do |req, path|
  req.path.match?(/\A#{LOCALE_PREFIX}#{path}\z/)
end

# ELB health checks are never throttled. They are a fixed, small set of ALB
# addresses, and a throttled health check would take the task out of service.
Rack::Attack.safelist('healthcheck') do |req|
  req.path == '/healthcheck'
end

# Login: brute-forcing passwords or probing accounts from one address.
Rack::Attack.throttle('users/sign_in/ip', limit: 10, period: 1.minute) do |req|
  req.ip if req.post? && RACK_ATTACK_PATH.call(req, '/users/sign_in')
end

# Registration: account creation spam.
Rack::Attack.throttle('users/registration/ip', limit: 10, period: 1.minute) do |req|
  req.ip if req.post? && RACK_ATTACK_PATH.call(req, '/users')
end

# Password reset: every request sends an email. Limit by IP so one client
# can't spam, and by target address so many IPs can't flood one inbox.
Rack::Attack.throttle('users/password/ip', limit: 5, period: 1.minute) do |req|
  req.ip if req.post? && RACK_ATTACK_PATH.call(req, '/users/password')
end

Rack::Attack.throttle('users/password/email', limit: 5, period: 1.hour) do |req|
  next unless req.post? && RACK_ATTACK_PATH.call(req, '/users/password')

  req.params.dig('user', 'email').to_s.strip.downcase.presence
end

# Everything else, per IP. Assets are excluded so page loads don't count.
# 1000 per 5 minutes is about 3 requests a second, which a shared venue
# address can reach legitimately.
Rack::Attack.throttle('req/ip', limit: 1000, period: 5.minutes) do |req|
  req.ip unless req.path.start_with?('/assets')
end

# Log each throttled request. The email address used as the discriminator for
# the password rule is deliberately not logged.
ActiveSupport::Notifications.subscribe('throttle.rack_attack') do |*, payload|
  req = payload[:request]

  Rails.logger.warn(
    {
      event: 'rack_attack.throttled',
      rule: req.env['rack.attack.matched'],
      ip: req.ip,
      method: req.request_method,
      path: req.path,
      user_agent: req.user_agent.to_s.truncate(200)
    }.to_json
  )
end
