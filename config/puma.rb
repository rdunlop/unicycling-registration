workers Integer(ENV.fetch("WEB_CONCURRENCY", 3))
threads 1, 1
worker_timeout 250
preload_app!

pidfile ENV.fetch("PIDFILE", "tmp/pids/puma.pid")
# In development or when PORT is set (e.g. ECS/Fargate), bind to TCP.
# Otherwise bind to the Unix socket that Nginx proxies to on EC2.
if ENV["PORT"]
  port ENV.fetch("PORT") { 3000 }
else
  bind ENV.fetch("PUMA_BIND", "unix:///tmp/puma-unicycling-registration.socket")
end

before_worker_boot do
  defined?(ActiveRecord::Base) &&
    ActiveRecord::Base.establish_connection
end
