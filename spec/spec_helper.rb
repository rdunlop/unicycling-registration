require 'simplecov'

# run coverage when on CI
if ENV['CI']
  SimpleCov.start 'rails' do
    add_filter '/spec/'
  end
end

require 'rubygems'
# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'capybara/rspec'
require 'capybara/poltergeist'
require "pundit/rspec"
require "shoulda/matchers"

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec", "support", "**", "*.rb")].each {|f| require f}

# This is required by CI because sometimes it runs the model specs before
# other rails specs (which would have initialized/created the following directories)
require 'fileutils'
FileUtils.mkdir_p Rails.root.join("tmp", "cache")

ActiveRecord::Migration.maintain_test_schema!

Capybara.javascript_driver = :poltergeist

RSpec.configure do |config|
  config.infer_spec_type_from_file_location!

  config.include(Shoulda::Matchers::ActiveModel, type: :model)
  config.include(Shoulda::Matchers::ActiveRecord, type: :model)
  config.include ActiveSupport::Testing::TimeHelpers

  config.example_status_persistence_file_path = "examples.txt"

  config.render_views
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

  config.before(:each) do
    # We do this instead of setting cache_store = :null_store
    # because sometimes we DO want caching enabled (see below)
    Rails.cache.clear
  end

  # Apartment Related
  config.before(:suite) do
    # Clean all tables to start
    DatabaseCleaner.clean_with :truncation
    # Use transactions for tests
    DatabaseCleaner.strategy = :transaction
    # Truncating doesn't drop schemas, ensure we're clean here, app *may not* exist
    begin
      Apartment::Tenant.drop('testing')
    rescue
      nil
    end
    # Create the default tenant for our tests
    tenant = Tenant.create!(description: 'Test Tenant', subdomain: 'testing', admin_upgrade_code: "TEST_UPGRADE_CODE")
    Apartment::Tenant.create(tenant.subdomain)
  end

  config.before(:each) do
    Apartment::Tenant.switch! 'testing'
  end

  config.after(:each) do
    Apartment::Tenant.reset
  end

  config.around(:each, :caching) do |example|
    caching = ActionController::Base.perform_caching
    ActionController::Base.perform_caching = example.metadata[:caching]
    example.run
    Rails.cache.clear
    ActionController::Base.perform_caching = caching
  end

  config.before(:each) do
    if EventConfiguration.instance_variable_defined?(:@singleton)
      EventConfiguration.remove_instance_variable(:@singleton)
    end
  end

  config.before(:each, type: :view) do
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

  # In order to cause .deliver_later to actually .deliver_now
  config.before(:each) do
    ActiveJob::Base.queue_adapter.perform_enqueued_jobs = true
    ActiveJob::Base.queue_adapter.perform_enqueued_at_jobs = true
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

# To enable using `allow` in FactoryGirl after(:stub) calls,
# https://github.com/thoughtbot/factory_girl/issues/703
FactoryGirl::SyntaxRunner.class_eval do
  include RSpec::Mocks::ExampleMethods
end
