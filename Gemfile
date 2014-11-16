source 'https://rubygems.org'

ruby "2.1.2"
gem 'rails', '4.1.7'

# Authentication
gem 'devise'
gem 'cancancan', '~> 1.9'
gem 'rolify'

# Output reports
gem 'wicked_pdf'
gem 'wkhtmltopdf-binary'
gem 'spreadsheet'
gem 'prawn-labels'

# Front-end
gem 'formtastic'
gem 'chosen-rails'
gem 'breadcrumbs_on_rails'
gem 'awesome_nested_fields'
gem 'fancybox2-rails', '~> 0.2.8'
gem 'font-kit-rails', :git => "git://github.com/sandelius/font-kit-rails.git", :ref => "480c979b84aa4d32652772822dee2366c37eed2e" # to get a change which includes font-url

# system utils
gem 'rake'
gem 'paper_trail', '~> 3.0.1'
gem 'exception_notification'
gem 'memcachier'
gem 'dalli'
gem 'rails_admin'
gem "fog"
gem 'http_accept_language'
gem 'newrelic_rpm'

# Model utils
gem 'acts_as_list'
gem 'carrierwave_direct'
gem 'carmen', '1.0.0' # locked to 1.0.0 because 1.0.1 removed Puerto Rico
gem 'carmen-rails'
gem 'globalize', '~> 4.0.2'
gem 'virtus'
gem "wicked"

#gem 'sqlite3'
gem 'pg'

group :naucc, :development, :caching do
  gem 'consistency_fail'
  gem 'better_errors'
  gem "binding_of_caller"
  gem 'simplecov', :require => false, :group => :test
end

group :naucc, :development, :test, :cucumber, :caching do
  gem 'capybara', github: 'jnicklas/capybara'
  gem 'poltergeist'
  gem 'annotate'
  gem 'bullet'
  #gem 'brakeman'
  gem 'factory_girl_rails'
  gem 'rspec-rails'
  gem 'spork-rails'
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

# Use unicorn as the app server
gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

# To use debugger
# gem 'ruby-debug19', :require => 'ruby-debug'
