source 'https://rubygems.org'

ruby File.open(File.expand_path(".ruby-version", File.dirname(__FILE__))) { |f| f.read.chomp }

git_source(:github) { |name| "https://github.com/#{name}.git" }

gem 'rails', '~> 7.0.8'
gem 'sprockets', '< 4' # Sprockets 4 pain is not worth it.

# Authentication
gem 'devise'
gem 'devise-i18n'
gem 'pundit'
gem 'rolify'

# Output reports
gem 'prawn'
gem 'matrix'
gem 'prawn-labels'
gem 'spreadsheet'
# ttfunk 1.8.0 has issues with embedded japanese fonts for BagLabels and Award Labels
# https://github.com/prawnpdf/ttfunk/issues/102
gem 'ttfunk', '1.7.0'
gem 'wicked_pdf'
gem 'wkhtmltopdf-binary', '0.12.3.1'
# newer versions of wkhtmltopdf seem to have shrunken fonts on Mac OS X

# Front-end
gem "autoprefixer-rails"
gem 'breadcrumbs_on_rails'
gem 'cocoon' # for nested forms
gem 'countries'
gem 'country_select'
gem 'fancybox2-rails', github: 'sureswiftcapital/fancybox2-rails', branch: "rails6" # for rails 6 support
gem 'foundation-rails'
gem "haml-rails"
gem 'importmap-rails'
gem 'jquery-datatables-rails'
gem 'jquery-rails'
gem 'jquery-ui-rails', '6.0.1'
gem 'money-rails'
gem 'rails-assets-datetimepicker', source: 'https://rails-assets.org'
gem 'recaptcha', require: 'recaptcha/rails'
gem 'select2-rails'
gem 'simple_form'
gem 'stimulus-rails'
gem 'tinymce-rails'
gem "validates_timeliness", "7.0.0.beta2" # for Ruby 3 support

# system utils
gem 'acme-client'
gem 'apartment_acme_client'
gem 'aws-sdk-rails'
gem 'dotenv-rails'
gem 'eye-patch', require: false
gem 'gaffe'
gem 'hcaptcha'
gem 'http_accept_language'
gem 'order_as_specified'
gem 'paper_trail'
gem 'rails_admin', '< 4'
gem 'rake'
gem 'redis'
gem 'request_store' # Supports EventConfiguration.singleton
gem 'rollbar'
gem 'rubyzip'
gem 'sassc-rails' # needed by rails_admin
gem 'sidekiq', '< 8' # as per sidekiq recommendations, always lock like this
gem 'stripe'
gem 'unicorn', require: false
gem 'whenever'

# I18n Translation
# use rdunlop branch which has:
#  fixed the Pagination-Load issue
#  specific import/export functions to match the translation-file structure used
# also, the released version of tolk does not yet support rails 5. (need to use `master`)
gem 'kaminari'
gem 'rails-i18n'
gem 'tolk', github: 'rdunlop/tolk', branch: 'improve_import_export'

# multi-tenancy
gem 'pry-rails' # required for apartment console customization
gem 'ros-apartment', require: 'apartment', github: 'rails-on-services/apartment', branch: 'development' # github version until version > 2.11.0 is released with Rails 7.1 support
gem 'ros-apartment-sidekiq', require: 'apartment-sidekiq'

# Model utils
gem 'acts_as_list'
gem 'carrierwave'
gem 'carrierwave-aws', '1.6.0'
gem 'carrierwave-i18n'
gem 'globalize', github: 'globalize/globalize', branch: 'main'
gem 'nilify_blanks'
gem 'validates_email_format_of'
gem 'virtus'
gem "wicked"

gem 'faker' # to support 'sample_data'

gem 'pg'

# deployment
gem 'capistrano', require: false
gem 'capistrano3-unicorn', require: false
gem 'capistrano-rails', require: false
gem 'capistrano-rvm', require: false

group :naucc, :development, :caching do
  gem 'consistency_fail'
end

group :test do
  gem 'capybara'
  gem 'codeclimate_circle_ci_coverage'
  gem 'database_cleaner'
  gem 'poltergeist'
  gem 'rspec_junit_formatter' # per circleCI https://circleci.com/docs/test-metadata
  gem 'rspec-rails'

  gem "shoulda-matchers", require: false

  gem 'rspec-instafail', require: false
end

group :development, :test do
  gem 'bundler-audit', require: false
  gem 'factory_bot_rails'
  gem 'rubocop', '0.93.1', require: false
  gem 'rubocop-rails', require: false
  gem 'rubocop-rspec', require: false
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
gem 'sass-rails'

gem 'uglifier', '>= 1.0.3'

# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# To use Jbuilder templates for JSON
# gem 'jbuilder'

# To use debugger
# gem 'ruby-debug19', :require => 'ruby-debug'
