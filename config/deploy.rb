set :eye_env, -> { { rails_env: fetch(:rails_env) } }
set :application, 'unicycling-registration'
set :repo_url, 'git@github.com:rdunlop/unicycling-registration.git'
set :stages, %w[prod]

# Default value for :linked_files is []
set :linked_files, %w[.env.local config/eye.rb public/robots.txt]

# Default value for linked_dirs is []
# .well-known is for letsencrypt
set :linked_dirs, %w[log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system public/sitemaps public/.well-known]

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
        puts local_diff.to_s
      end
    end
  end
end
# rubocop:enable Rails/Output

set :whenever_command,      -> { %i[bundle exec whenever] }
set :whenever_environment,  -> { fetch :rails_env }
set :whenever_identifier,   -> { fetch :application }
set :whenever_roles,        -> { %i[db app] }

set :rollbar_token, ENV["ROLLBAR_ACCESS_TOKEN"]
set :rollbar_env, proc { fetch :rails_env }
set :rollbar_role, proc { :app }

# EYE (and via eye, sidekiq and unicorn)
set :eye_config, -> { "config/eye.rb" }
set :eye_bin, -> { :eye }
set :eye_roles, -> { :app }
set :eye_env, -> { {} }

set :chruby_map_bins, fetch(:chruby_map_bins, []).push(fetch(:eye_bin))
set :rvm_map_bins, fetch(:rvm_map_bins, []).push(fetch(:eye_bin))
set :rbenv_map_bins, fetch(:rbenv_map_bins, []).push(fetch(:eye_bin))
set :bundle_bins, fetch(:bundle_bins, []).push(fetch(:eye_bin))

namespace :eye do
  desc "Start eye with the desired configuration file"
  task :load_config do
    on roles(fetch(:eye_roles)) do
      within current_path do
        with fetch(:eye_env) do
          execute fetch(:eye_bin), "quit"
          # With ruby 3.1, on Amazon Linux 2023, the following
          # command is hanging unless we have a PTY.
          SSHKit::Backend::Netssh.config.pty = true
          execute fetch(:eye_bin), "load #{fetch(:eye_config)}"
        end
      end
    end
  end

  desc "Start eye with the desired configuration file"
  task :start, :load_config

  desc "Stop eye and all of its monitored tasks"
  task :stop do
    on roles(fetch(:eye_roles)) do
      within current_path do
        with fetch(:eye_env) do
          execute fetch(:eye_bin), "stop all"
          execute fetch(:eye_bin), "quit"
        end
      end
    end
  end

  desc "Restart all tasks monitored by eye"
  task restart: :load_config do
    on roles(fetch(:eye_roles)) do
      within current_path do
        with fetch(:eye_env) do
          execute fetch(:eye_bin), "restart all"
        end
      end
    end
  end
end

if fetch(:eye_default_hooks, true)
  after "deploy:publishing", "deploy:restart"

  namespace :deploy do
    task :restart do
      invoke "eye:restart"
    end
  end
end
