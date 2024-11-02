# Load DSL and Setup Up Stages
require 'capistrano/setup'

# Includes default deployment tasks
require 'capistrano/deploy'

require 'capistrano/rvm'
require 'capistrano/bundler'
require 'capistrano/rails/migrations'
require 'capistrano/rails/assets'
require "capistrano/scm/git"
require 'capistrano/sidekiq'
install_plugin Capistrano::SCM::Git

require "whenever/capistrano"

# Loads custom tasks from `lib/capistrano/tasks' if you have any defined.
Dir.glob('lib/capistrano/tasks/*.cap').each { |r| import r }

require "rollbar/capistrano3"

require 'capistrano3/unicorn'

install_plugin Capistrano::Sidekiq  # Default sidekiq tasks
install_plugin Capistrano::Sidekiq::Systemd
