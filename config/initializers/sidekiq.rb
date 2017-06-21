require "sidekiq/middleware/i18n"

# In order to prevent the EventConfiguration from being incorrectly
# cached throughout multiple sidekiq messages, we clear it before each
# processing step
class MyClientMiddleware
  def call(_worker_class, _job, _queue, _redis_pool)
    RequestStore.clear!
    yield
  end
end

class MyMiddleware
  def initialize(options = nil); end

  def call(_worker, _msg, _queue)
    RequestStore.clear!
    yield
  end
end

unless Rails.env.test?
  Sidekiq.configure_server do |config|
    config.redis = Redis.sidekiq_configuration

    config.client_middleware do |chain|
      chain.add MyClientMiddleware
    end
    config.server_middleware do |chain|
      chain.add MyMiddleware
    end
  end

  Sidekiq.configure_client do |config|
    config.redis = Redis.sidekiq_configuration
  end
end
