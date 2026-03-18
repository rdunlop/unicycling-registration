workers Integer(ENV.fetch("WEB_CONCURRENCY", 3))
worker_timeout 250
preload_app!

before_worker_boot do
  defined?(ActiveRecord::Base) &&
    ActiveRecord::Base.establish_connection
end
