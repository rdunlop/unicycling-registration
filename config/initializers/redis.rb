class Redis
  def self.cache_configuration
    if ENV["REDIS_CACHE_URL"]
      # ECS: dedicated cache sidecar (redis://127.0.0.1:6379/1 set by task definition)
      { url: ENV["REDIS_CACHE_URL"], expires_in: 1.year, namespace: -> { "CACHE_#{Apartment::Tenant.current}" } }
    else
      # EC2: legacy host/port/db config
      configuration do |config|
        config[:expires_in] = 1.year
        config[:namespace] = -> { "CACHE_#{Apartment::Tenant.current}" }
      end
    end
  end

  def self.sidekiq_configuration
    if ENV["REDIS_URL"]
      # ECS: ElastiCache via URL (shared across all containers)
      { url: ENV["REDIS_URL"] }
    else
      # EC2: legacy host/port/db config; sidekiq uses db+1 to avoid colliding with cache
      configuration do |config|
        config[:db] += 1
      end
    end
  end

  def self.configuration
    config = {
      host: ::Rails.configuration.redis_host,
      port: ::Rails.configuration.redis_port,
      db: ::Rails.configuration.redis_db
    }

    yield config

    config
  end
end
