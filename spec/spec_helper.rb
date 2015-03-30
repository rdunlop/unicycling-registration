require 'simplecov'
SimpleCov.start 'rails' do
  add_filter '/spec/'
end
require 'rubygems'
require 'delorean'
# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'cancan/matchers'
require 'capybara/rspec'
require 'capybara/poltergeist'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

ActiveRecord::Migration.maintain_test_schema!

Capybara.javascript_driver = :poltergeist

RSpec.configure do |config|

  config.infer_spec_type_from_file_location!

  # ## Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr
  if ENV["CI"]
    # config.filter_run_excluding :pdf_generation => true
  end

  config.around(:each, :caching) do |example|
    caching = ActionController::Base.perform_caching
    ActionController::Base.perform_caching = example.metadata[:caching]
    example.run
    Rails.cache.clear
    ActionController::Base.perform_caching = caching
  end

  config.before(:each, :type => :view) do
    assign(:config, EventConfiguration.new)
  end


  # this is necessary so that spec path builders without locales don't
  # incorrectly specify positional arguments into the 'locale' argument
  config.before(:each, type: :feature) do
    default_url_options[:locale] = I18n.default_locale
  end
  config.before :each, type: :view do
    controller.default_url_options[:locale] = I18n.default_locale
  end

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  config.after type: :feature do
    Warden.test_reset!
  end

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  # If true, the base class of anonymous controllers will be inferred
  # automatically. This will be the default behavior in future versions of
  # rspec-rails.
  config.infer_base_class_for_anonymous_controllers = false

  # Default to using inline, meaning all jobs will run as they're
  # called. Since we primarily are using this for email, this ensures
  # the emails go immediately to ActionMailer::Base.deliveries
  require 'sidekiq/testing'
  config.before(:each) do
    Sidekiq::Worker.clear_all
  end

  config.around(:each) do |example|
    if example.metadata[:sidekiq] == :fake
      Sidekiq::Testing.fake!(&example)
    else
      Sidekiq::Testing.inline!(&example)
    end
  end

  # config.include Devise::TestHelpers, type: :controller
  config.include Warden::Test::Helpers, type: :feature

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = "random"
end
