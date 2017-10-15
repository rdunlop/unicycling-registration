source 'https://rubygems.org'

ruby File.open(File.expand_path(".ruby-version", File.dirname(__FILE__))) { |f| f.read.chomp }

git_source(:github) { |name| "https://github.com/#{name}.git" }

gem 'rails', '~> 5.1.0'

# Authentication
gem 'devise'
gem 'devise-i18n'
gem 'pundit'
gem 'rolify'

# Output reports
gem 'prawn-labels'
gem 'spreadsheet'
gem 'wicked_pdf'
gem 'wkhtmltopdf-binary'

# Front-end
gem "autoprefixer-rails"
gem 'breadcrumbs_on_rails'
gem 'cocoon' # for nested forms
gem 'countries', github: 'rdunlop/countries', branch: 'iuf_country_changes' # necessary to be able to specify non-ISO3166 countries
gem 'country_select'
gem 'fancybox2-rails', github: 'rdunlop/fancybox2-rails', branch: "rails5" # for rails 5 support
gem 'foundation-rails'
gem "haml-rails"
gem "jc-validates_timeliness"
gem 'jquery-datatables-rails'
gem 'jquery-datetimepicker-rails'
gem 'jquery-rails'
gem 'jquery-ui-rails'
gem 'money-rails'
gem 'recaptcha', require: 'recaptcha/rails'
gem 'select2-rails'
gem 'simple_form'
gem 'tinymce-rails'

# system utils
gem 'acme-client'
gem 'aws-sdk-rails'
gem 'eye-patch', require: false
gem 'gaffe'
gem 'http_accept_language'
gem 'newrelic_rpm'
gem 'order_as_specified'
gem 'paper_trail'
gem 'rails_admin'
gem 'rake'
gem 'redis-namespace'
gem 'redis-rails'
gem 'redis-store'
gem 'request_store' # Supports EventConfiguration.singleton
gem 'rollbar'
gem 'rubyzip'
gem 'sidekiq', '< 6' # as per sidekiq recommendations, always lock like this
gem 'unicorn', require: false
gem 'whenever'

# determined we are over IE8 CSS limits using
# http://stackoverflow.com/questions/9906794/internet-explorers-css-rules-limits
gem 'css_splitter' # support ie9 css rule limits

# I18n Translation
# use rdunlop branch which has:
#  fixed the Pagination-Load issue
#  specific import/export functions to match the translation-file structure used
# also, the released version of tolk does not yet support rails 5. (need to use `master`)
gem 'kaminari'
gem 'rails-i18n'
gem 'tolk', github: 'rdunlop/tolk', branch: 'improve_import_export'

# multi-tenancy
gem 'apartment'
gem 'apartment-sidekiq', github: "tmster/apartment-sidekiq" # apartment 2.0 support
# https://github.com/influitive/apartment-sidekiq/pull/19

# Model utils
gem 'acts_as_restful_list', github: 'rdunlop/acts_as_restful_list'
gem 'carrierwave'
gem 'carrierwave-aws'
gem 'carrierwave-i18n'
gem 'globalize', github: 'globalize/globalize' # necessary for rails 5 support. Must be gem > 5.0.1
gem 'nilify_blanks'
gem 'validates_email_format_of'
gem 'virtus'
gem "wicked"

gem 'faker' # to support 'sample_data'

gem 'pg'

# deployment
gem 'capistrano', require: false
gem 'capistrano-rails', require: false
gem 'capistrano-rvm', require: false
gem 'capistrano3-unicorn', require: false

group :naucc, :development, :caching do
  gem 'consistency_fail'
  gem 'rubocop', require: false
end

group :test do
  gem 'capybara'
  gem 'codeclimate_circle_ci_coverage'
  gem 'database_cleaner'
  gem 'factory_girl_rails', '4.7.0' # https://github.com/thoughtbot/factory_girl/pull/982
  gem 'poltergeist'
  gem 'rspec-rails'
  gem 'rspec_junit_formatter' # per circleCI https://circleci.com/docs/test-metadata

  gem "shoulda-matchers", require: false

  gem 'rspec-instafail', require: false
end

group :development, :test do
  gem 'teaspoon-jasmine'
end

group :unicon, :naucc, :development, :test, :cucumber, :caching do
  gem 'annotate'
  gem 'bullet'
  # gem 'brakeman'
  gem 'foreman'
  gem 'pry'
  gem 'watchr'
end

# Gems used only for assets and not required
# in production environments by default.
gem 'coffee-rails'
gem 'sass-rails'

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
