source 'https://rubygems.org'

ruby "2.1.2"
gem 'rails', '4.1.8'

# Authentication
gem 'devise'
gem 'devise-async'
gem 'cancancan', '~> 1.10'
gem 'rolify'

# Output reports
gem 'wicked_pdf'
gem 'wkhtmltopdf-binary'
gem 'spreadsheet'
gem 'prawn-labels'

# Front-end
gem 'simple_form'
gem 'country_select'
gem 'chosen-rails'
gem 'breadcrumbs_on_rails'
gem 'awesome_nested_fields'
gem 'fancybox2-rails', '~> 0.2.8'
gem 'font-kit-rails', :git => "git://github.com/sandelius/font-kit-rails.git", :ref => "480c979b84aa4d32652772822dee2366c37eed2e" # to get a change which includes font-url

# system utils
gem 'rake'
gem 'paper_trail', '~> 3.0.1'
gem 'exception_notification'
gem 'redis-store', git: "git://github.com/rdunlop/redis-store.git" # necessary for lambda namespace (https://github.com/redis-store/redis-store/pull/163)
gem 'redis-rails'
gem 'rails_admin'
gem "fog"
gem 'aws-sdk'
gem 'http_accept_language'
gem 'newrelic_rpm'
gem 'sidekiq'
# if you require 'sinatra' you get the Sinatra DSL extended to Object
gem 'sinatra', '>= 1.3.0', :require => nil # necessary for sidekiq routing
gem 'unicorn'
gem 'whenever'
gem 'rubocop', require: false

# multi-tenancy
gem 'apartment'
gem 'apartment-sidekiq'

# Model utils
gem 'acts_as_list'
gem 'carrierwave_direct'
gem 'carmen', '1.0.0' # locked to 1.0.0 because 1.0.1 removed Puerto Rico
gem 'carmen-rails'
gem 'globalize', '~> 4.0.3'
gem 'virtus'
gem "wicked"

# gem 'sqlite3'
gem 'pg'

# deployment
gem 'capistrano'
gem 'capistrano-rails'
gem 'capistrano-rvm'
gem 'capistrano-bundler'
gem 'capistrano3-unicorn'
gem 'capistrano-sidekiq' , github: 'seuros/capistrano-sidekiq'

group :naucc, :development, :caching do
  gem 'quiet_assets'
  gem 'consistency_fail'
  gem 'better_errors'
  gem "binding_of_caller"
  gem 'simplecov', :require => false, :group => :test
end

group :unicon, :naucc, :development, :test, :cucumber, :caching do
  gem 'capybara', github: 'jnicklas/capybara'
  gem 'poltergeist'
  gem 'annotate'
  gem 'bullet'
  # gem 'brakeman'
  gem 'factory_girl_rails'
  gem 'rspec-rails'
  gem 'rspec-instafail', require: false
  gem 'syntax'
  gem 'watchr'
  gem 'foreman'
  gem 'delorean'
  gem 'pry'
end

# Gems used only for assets and not required
# in production environments by default.
gem 'sass-rails'
gem 'coffee-rails'

# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer'

gem 'uglifier', '>= 1.0.3'

gem 'jquery-rails'

# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# To use Jbuilder templates for JSON
# gem 'jbuilder'

# To use debugger
# gem 'ruby-debug19', :require => 'ruby-debug'
