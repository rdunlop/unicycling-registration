require "socket"

# ---------------------------------------------------------------------------
# Latency benchmark — database + cache
# Run on EC2:  bundle exec rails runner script/benchmark_performance.rb
# Run on ECS:  aws ecs execute-command --cluster <cluster> --task <task-id> \
#                --container web --interactive \
#                --command "bundle exec rails runner script/benchmark_performance.rb"
# ---------------------------------------------------------------------------

N = 300

def pct(sorted, p)
  sorted[[(sorted.size * p / 100.0).ceil - 1, 0].max]
end

def measure(n, &block)
  # one warmup pass
  block.call
  times = n.times.map do
    t = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    block.call
    (Process.clock_gettime(Process::CLOCK_MONOTONIC) - t) * 1000.0
  end
  s = times.sort
  { mean: times.sum / times.size, p50: pct(s, 50), p95: pct(s, 95), p99: pct(s, 99) }
end

def row(label, r)
  puts format("  %-38s  mean=%7.3fms  p50=%7.3fms  p95=%7.3fms  p99=%7.3fms", label, r[:mean], r[:p50], r[:p95], r[:p99])
end

puts
puts "=" * 90
puts "  Host:        #{Socket.gethostname}"
puts "  RAILS_ENV:   #{Rails.env}"
puts "  Cache store: #{Rails.cache.class}"
puts "  DB adapter:  #{ActiveRecord::Base.connection.adapter_name}"
puts "  DB host:     #{ActiveRecord::Base.connection_db_config.host}"
puts "  Time:        #{Time.current}"
puts "=" * 90

conn = ActiveRecord::Base.connection

# ---- Database ---------------------------------------------------------------
puts "\n--- Database (n=#{N} each) ---\n\n"

row "SELECT 1 (connection ping)",
    measure(N) { conn.execute("SELECT 1") }

row "SELECT current_timestamp",
    measure(N) { conn.execute("SELECT current_timestamp") }

# Use a public-schema table that always exists
row "SELECT COUNT(*) FROM schema_migrations",
    measure(N) { conn.execute("SELECT COUNT(*) FROM schema_migrations") }

# Checkout + checkin from pool (connection pool overhead)
row "connection pool checkout+checkin",
    measure(N) {
      ActiveRecord::Base.connection_pool.with_connection { |c| c.execute("SELECT 1") }
    }

# AR model query — switch to a known tenant if Apartment is active
begin
  tenant = Apartment.tenant_names.first
  if tenant
    Apartment::Tenant.switch(tenant) do
      row "User.count (tenant: #{tenant})",
          measure(N) { User.count }
      row "User.first",
          measure(N) { User.first }
    end
  end
rescue StandardError => e
  puts "  (skipped AR model queries: #{e.message})"
end

# ---- Cache ------------------------------------------------------------------
puts "\n--- Cache: #{Rails.cache.class} (n=#{N} each) ---\n\n"

if Rails.cache.is_a?(ActiveSupport::Cache::NullStore)
  puts "  Cache is NullStore — skipping (configure REDIS_CACHE_URL to enable)"
else
  key   = "benchmark/#{SecureRandom.hex(6)}"
  val1k = "x" * 1024    # 1 KB
  val10k = "x" * 10_240 # 10 KB

  Rails.cache.write(key, val1k)

  row "write 1 KB",
      measure(N) { Rails.cache.write(key, val1k) }

  row "read hit (1 KB cached)",
      measure(N) { Rails.cache.read(key) }

  Rails.cache.delete(key)
  row "read miss",
      measure(N) { Rails.cache.read(key) }

  row "write 10 KB",
      measure(N) { Rails.cache.write(key, val10k) }

  row "read hit (10 KB cached)",
      measure(N) { Rails.cache.read(key) }

  row "fetch miss (write on miss)",
      measure(N) {
        Rails.cache.delete(key)
        Rails.cache.fetch(key) { val1k }
      }

  Rails.cache.write(key, val1k)
  row "fetch hit (already cached)",
      measure(N) { Rails.cache.fetch(key) { val1k } }

  row "delete",
      measure(N) {
        Rails.cache.write(key, val1k)
        Rails.cache.delete(key)
      }

  Rails.cache.delete(key)
end

puts
puts "=" * 90
puts "Done."
puts
