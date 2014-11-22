Workspace::Application.configure do
  config.after_initialize do
    PaperTrail.enabled = false
  end
  # Settings specified here will take precedence over those in config/application.rb.
  config.action_mailer.default_url_options = { :host => 'localhost:9292' }

  # The test environment is used exclusively to run your application's
  # test suite. You never need to work with it otherwise. Remember that
  # your test database is "scratch space" for the test suite and is wiped
  # and recreated between test runs. Don't rely on the data there!
  config.cache_classes = true

  # Do not eager load code on boot. This avoids loading your whole application
  # just for the purpose of running a single test. If you are using a tool that
  # preloads Rails for running tests, you may have to set it to true.
  config.eager_load = false

  config.active_record.maintain_test_schema = true

  # Configure static asset server for tests with Cache-Control for performance.
  config.serve_static_assets  = true
  config.static_cache_control = "public, max-age=3600"

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Raise exceptions instead of rendering exception templates.
  config.action_dispatch.show_exceptions = false

  # Disable request forgery protection in test environment.
  config.action_controller.allow_forgery_protection = false

  # Tell Action Mailer not to deliver emails to the real world.
  # The :test delivery method accumulates sent emails in the
  # ActionMailer::Base.deliveries array.
  config.action_mailer.delivery_method = :test

  config.assets.raise_runtime_errors = true

  # Print deprecation notices to the stderr.
  config.active_support.deprecation = :stderr
end

# Necessary to allow the tests to execute when they don't have a locale defined.
#  As per (https://github.com/rspec/rspec-rails/issues/255)
# Rails 4
class ActionDispatch::Routing::RouteSet::NamedRouteCollection::UrlHelper
  def call(t, args)
    t.url_for(handle_positional_args(t, args, { locale: I18n.default_locale }.merge( @options ), @segment_keys))
  end
end

# Rails 3
#class ActionDispatch::Routing::RouteSet
#  def url_for_with_locale_fix(options)
#    url_for_without_locale_fix({:locale => I18n.default_locale}.merge(options))
#  end
#
#  alias_method_chain :url_for, :locale_fix
#end

