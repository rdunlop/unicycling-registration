# see https://github.com/sosedoff/capistrano-unicorn/blob/master/examples/rails3.rb
# see https://ariejan.net/2011/09/14/lighting-fast-zero-downtime-deployments-with-git-capistrano-nginx-and-unicorn/

# workers - this has to be higher than 1 in order to run phantomjs commands while
# not interrupting the other process
worker_processes 2

# listen
listen 8080

# preload
preload_app true

# paths
app_path = File.expand_path("../../..", __FILE__)
working_directory app_path
pid "tmp/pids/unicorn.pid"

after_fork do |_server, _worker|
  ActiveRecord::Base.establish_connection if defined?(ActiveRecord::Base)
end
