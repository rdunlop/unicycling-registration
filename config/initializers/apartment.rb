# Require whichever elevator you're using below here...
#
require 'apartment/elevators/generic'
# require 'apartment/elevators/domain'
# require 'apartment/elevators/subdomain'

#
# Apartment Configuration
#
Apartment.configure do |config|
  # These models will not be multi-tenanted,
  # but remain in the global (public) namespace
  #
  # An example might be a Customer or Tenant model that stores each tenant information
  # ex:
  #
  # config.excluded_models = %w{Tenant}
  #
  config.excluded_models = %w(Tenant TenantAlias Tolk::Locale Tolk::Translation Tolk::Phrase)

  # use postgres schemas?
  config.use_schemas = true

  # use raw SQL dumps for creating postgres schemas? (only appies with use_schemas set to true)
  # config.use_sql = true

  # configure persistent schemas (E.g. hstore )
  # config.persistent_schemas = %w{ hstore }

  # add the Rails environment to database names?
  # config.prepend_environment = true
  # config.append_environment = true

  # supply list of database names for migrations to run on
  config.tenant_names = ->{ Tenant.pluck :subdomain }
end

##
# Elevator Configuration

unless Rails.env.test?
  Rails.application.config.middleware.use 'Apartment::Elevators::Generic', lambda { |request|
    Tenant.find_tenant_by_hostname(request.host).try(:subdomain) || "public"
  }
end

# Rails.application.config.middleware.use 'Apartment::Elevators::Domain'

# Rails.application.config.middleware.use 'Apartment::Elevators::Subdomain' unless Rails.env.test?
