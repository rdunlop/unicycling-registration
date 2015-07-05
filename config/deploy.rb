# config valid only for Capistrano 3.1
lock '3.4.0'

set :application, 'unicycling-registration'
set :repo_url, 'git@github.com:rdunlop/unicycling-registration.git'
set :stages, %w(prod)

# Default value for :linked_files is []
set :linked_files, %w(config/database.yml config/secrets.yml config/newrelic.yml public/robots.txt)

# Default value for linked_dirs is []
set :linked_dirs, %w(bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system public/sitemaps)

before 'deploy', 'sidekiq:stop'
after 'deploy:publishing', 'deploy:restart'
namespace :deploy do
  task :restart do
    invoke 'unicorn:restart'
  end
end

namespace :deploy do
  task install_translations: [:set_rails_env] do
    on primary(:app) do
      within release_path do
        with rails_env: fetch(:rails_env) do
          execute :rake, "import_translations_from_yml"
          execute :rake, "write_tolk_to_disk"
        end
      end
    end
  end
end
after 'deploy:published', 'deploy:install_translations'

# rubocop:disable Rails/Output
namespace :translation do
  task :download do
    local_diff = `git status --untracked-files=no --porcelain`
    on primary(:app) do
      if local_diff.empty?
        FileUtils.rm_rf "config/locales"
        download! "#{release_path}/config/locales/", "config/", recursive: true
      else
        puts "****** ERROR *******"
        puts "For safety purposes you cannot run this with a dirty local git directory"
        puts "Changes local:"
        puts "#{local_diff}"
      end
    end
  end
end

set :whenever_command,      ->{ [:bundle, :exec, :whenever] }
set :whenever_environment,  ->{ fetch :rails_env }
set :whenever_identifier,   ->{ fetch :application }
set :whenever_roles,        ->{ [:db, :app] }
