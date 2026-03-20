workers Integer(ENV.fetch("WEB_CONCURRENCY", 3))
threads 1, 1
worker_timeout 250
preload_app!

pidfile ENV.fetch("PIDFILE", "tmp/pids/puma.pid")
bind ENV.fetch("PUMA_BIND", "unix:///tmp/puma-unicycling-registration.socket")

before_worker_boot do
  defined?(ActiveRecord::Base) &&
    ActiveRecord::Base.establish_connection
end
