source 'https://rubygems.org'

ruby "2.2.3"
gem 'rails', '4.2.5.2'

# Authentication
gem 'devise'
gem 'devise-i18n'
gem 'devise-async'
gem 'pundit'
gem 'rolify'

# Output reports
gem 'wicked_pdf'
gem 'wkhtmltopdf-binary'
gem 'spreadsheet'
gem 'prawn-labels'

# Front-end
gem 'simple_form'
gem 'countries', github: 'rdunlop/countries', branch: 'iuf_country_changes' # necessary to be able to specify non-ISO3166 countries
gem 'country_select'
gem 'money-rails'
gem 'select2-rails'
gem 'breadcrumbs_on_rails'
gem 'awesome_nested_fields'
gem 'fancybox2-rails', '~> 0.2.8'
gem 'tinymce-rails'
gem 'recaptcha', require: 'recaptcha/rails'
gem 'jquery-datetimepicker-rails'
gem "jc-validates_timeliness"
gem 'foundation-rails'
gem "haml-rails", "~> 0.9"
gem "autoprefixer-rails"
gem 'jquery-rails'
gem 'jquery-ui-rails'
gem 'jquery-datatables-rails', '~> 3.3.0'

# system utils
gem 'rake'
gem 'paper_trail', '~> 3.0.1'
gem 'exception_notification'
gem 'redis-store', github: "rdunlop/redis-store" # necessary for lambda namespace (https://github.com/redis-store/redis-store/pull/163)
gem 'redis-rails'
gem 'rails_admin'
gem "rails_admin_pundit", github: "sudosu/rails_admin_pundit"
gem "fog"
gem 'aws-sdk-rails'
gem 'http_accept_language'
gem 'newrelic_rpm'
gem 'redis-namespace'
gem 'sidekiq', '< 5'
# if you require 'sinatra' you get the Sinatra DSL extended to Object
gem 'sinatra', '>= 1.3.0', require: nil # necessary for sidekiq routing
gem 'unicorn', require: false
gem 'whenever'
gem 'gaffe'
gem 'rubyzip'

# determined we are over IE8 CSS limits using
# http://stackoverflow.com/questions/9906794/internet-explorers-css-rules-limits
gem 'css_splitter' # support ie9 css rule limits

# I18n Translation
# use rdunlop branch which has:
#  fixed the Pagination-Load issue
#  specific import/export functions to match the translation-file structure used
gem 'tolk', github: 'rdunlop/tolk', branch: 'improve_import_export'
gem 'kaminari'
gem 'rails-i18n', '~> 4.0.0' # For 4.0.x

# multi-tenancy
gem 'apartment'
gem 'apartment-sidekiq', '= 0.2.0' # upgrading to 1.0.0 caused ActiveRecord::ConnectionTimeoutError

# Model utils
gem 'acts_as_restful_list', github: 'rdunlop/acts_as_restful_list'
gem 'carrierwave_direct'
gem 'globalize', '~> 5.0.0'
gem 'virtus'
gem "wicked"

gem 'faker' # to support 'sample_data'

gem 'pg'

# deployment
gem 'capistrano'
gem 'capistrano-rails'
gem 'capistrano-rvm'
gem 'capistrano-bundler'
gem 'capistrano3-unicorn'
gem 'capistrano-sidekiq', github: 'seuros/capistrano-sidekiq'

group :naucc, :development, :caching do
  gem 'quiet_assets'
  gem 'consistency_fail'
  gem 'web-console', '~> 2.0'
  gem "binding_of_caller"
  gem 'rubocop', require: false
end

group :test do
  gem 'codeclimate_circle_ci_coverage'
  gem 'capybara', github: 'jnicklas/capybara'
  gem 'poltergeist'
  gem 'factory_girl_rails'
  gem 'rspec-rails'
  gem 'rspec_junit_formatter', '0.2.2' # locked to 0.2.2 as per circleCI https://circleci.com/docs/test-metadata

  # locked to 3.0.1 because https://github.com/thoughtbot/shoulda-matchers/issues/904
  # causes is_expected.not_to validate_presence_of(:address) to fail with an obscure message
  gem "shoulda-matchers", "= 3.0.1", require: false

  gem 'rspec-instafail', require: false
  gem 'delorean'
end

group :development, :test do
  gem 'teaspoon-jasmine'
end

group :unicon, :naucc, :development, :test, :cucumber, :caching do
  gem 'annotate'
  gem 'bullet'
  # gem 'brakeman'
  gem 'watchr'
  gem 'foreman'
  gem 'pry'
end

# Gems used only for assets and not required
# in production environments by default.
gem 'sass-rails'
gem 'coffee-rails'

# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# Necessary so that the uglifier can process/compress the assets
gem 'therubyracer'

gem 'uglifier', '>= 1.0.3'

# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# To use Jbuilder templates for JSON
# gem 'jbuilder'

# To use debugger
# gem 'ruby-debug19', :require => 'ruby-debug'
