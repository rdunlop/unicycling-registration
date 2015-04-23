# config valid only for Capistrano 3.1
lock '3.3.5'

set :application, 'unicycling-registration'
set :repo_url, 'git@github.com:rdunlop/unicycling-registration.git'
set :stages, %w(prod)

# Default value for :linked_files is []
set :linked_files, %w{config/database.yml config/secrets.yml config/newrelic.yml public/robots.txt}

# Default value for linked_dirs is []
set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system public/sitemaps config/custom_locales}

before 'deploy', 'sidekiq:stop'
after 'deploy:publishing', 'deploy:restart'
namespace :deploy do
  task :restart do
    invoke 'unicorn:restart'
  end
end

namespace :deploy do
  task :install_translations => [:set_rails_env] do
    on primary(:app) do
      within release_path do
        with :rails_env => fetch(:rails_env) do
          execute :rake, "import_translations_from_yml"
        end
      end
    end
  end
end
after 'deploy:published', 'deploy:install_translations'

namespace :translation do
  task :download do
    on primary(:app) do
      download! "#{release_path}/config/custom_locales/", "config/", recursive: true
      FileUtils.rm_rf "config/locales"
      FileUtils.mv "config/custom_locales/", "config/locales"
    end
  end

  task :prime do
    on primary(:app) do
       execute "cp -R #{release_path}/config/locales/* #{release_path}/config/custom_locales/"
     end
   end
end

set :whenever_command,      ->{ [:bundle, :exec, :whenever] }
set :whenever_environment,  ->{ fetch :rails_env }
set :whenever_identifier,   ->{ fetch :application }
set :whenever_roles,        ->{ [:db, :app] }
