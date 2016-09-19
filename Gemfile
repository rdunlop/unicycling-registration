source 'https://rubygems.org'

ruby "2.2.3"
gem 'rails'

# Authentication
gem 'devise'
gem 'devise-i18n'
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
gem 'cocoon' # for nested forms
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
gem 'jquery-datatables-rails'

# system utils
gem 'rake'
gem 'paper_trail'
gem 'rollbar'
gem 'redis-store'
gem 'redis-rails'
gem 'rails_admin', '= 1.0.0.rc' # pre-release necessary to support rails 5
gem "rails_admin_pundit", github: "sudosu/rails_admin_pundit"
gem 'aws-sdk-rails'
gem 'http_accept_language'
gem 'newrelic_rpm'
gem 'redis-namespace'
gem 'sidekiq', '< 5'
gem 'unicorn', require: false
gem 'whenever'
gem 'gaffe'
gem 'rubyzip'
gem 'acme-client'
gem 'eye-patch', require: false
gem 'order_as_specified'

# determined we are over IE8 CSS limits using
# http://stackoverflow.com/questions/9906794/internet-explorers-css-rules-limits
gem 'css_splitter' # support ie9 css rule limits

# I18n Translation
# use rdunlop branch which has:
#  fixed the Pagination-Load issue
#  specific import/export functions to match the translation-file structure used
# also, the released version of tolk does not yet support rails 5. (need to use `master`)
gem 'tolk', github: 'rdunlop/tolk', branch: 'improve_import_export'
gem 'kaminari'
gem 'rails-i18n'

# multi-tenancy
gem 'apartment'
gem 'apartment-sidekiq'

# Model utils
gem 'acts_as_restful_list', github: 'rdunlop/acts_as_restful_list'
gem 'carrierwave'
gem 'carrierwave-aws'
gem 'globalize', '~> 5.0.0'
gem 'virtus'
gem "wicked"
gem 'validates_email_format_of'

gem 'faker' # to support 'sample_data'

gem 'pg'

# deployment
gem 'capistrano'
gem 'capistrano-rails'
gem 'capistrano-rvm'
gem 'capistrano-bundler'
gem 'capistrano3-unicorn'
gem "capistrano-deploytags", require: false

group :naucc, :development, :caching do
  gem 'quiet_assets'
  gem 'consistency_fail'
  gem 'rubocop', require: false
end

group :test do
  gem 'codeclimate_circle_ci_coverage'
  gem 'capybara', github: 'jnicklas/capybara'
  gem 'poltergeist'
  gem 'factory_girl_rails'
  gem 'rspec-rails'
  gem 'rspec_junit_formatter' # per circleCI https://circleci.com/docs/test-metadata

  # locked to 3.0.1 because https://github.com/thoughtbot/shoulda-matchers/issues/904
  # causes is_expected.not_to validate_presence_of(:address) to fail with an obscure message
  gem "shoulda-matchers", "= 3.0.1", require: false

  gem 'rspec-instafail', require: false
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
