# config valid only for Capistrano 3.1
lock '3.2.1'

set :application, 'unicycling-registration'
set :repo_url, 'git@github.com:rdunlop/unicycling-registration.git'
set :stages, %w(prod)

# Default value for :linked_files is []
set :linked_files, %w{config/database.yml config/secrets.yml config/newrelic.yml}

# Default value for linked_dirs is []
set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system public/sitemaps}

after 'deploy:publishing', 'deploy:restart'
namespace :deploy do
  task :restart do
    invoke 'unicorn:restart'
  end
end

set :whenever_command,      ->{ [:bundle, :exec, :whenever] }
set :whenever_environment,  ->{ fetch :rails_env }
set :whenever_identifier,   ->{ fetch :application }
set :whenever_roles,        ->{ [:db, :app] }
