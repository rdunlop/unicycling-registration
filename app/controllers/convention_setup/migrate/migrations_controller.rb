class ConventionSetup::Migrate::MigrationsController < ApplicationController
  before_action :load_source_tenant, except: :index
  before_action :authenticate_user!
  before_action :authorize_setup

  # Choose the tenant to copy from
  def index
    @tenants = Tenant.all - [@tenant]
  end

  def events
    Apartment::Tenant.switch @source_tenant.subdomain do
      @events = Event.all.load
    end
  end

  # Receive a single tenant, and a list of events
  # creates the matching events in the current tenant
  def create_events
    copier = EventCopier.new(@source_tenant.subdomain)
    copier.copy_events
    successes = copier.successes
    errors = copier.errors
    error_events = copier.error_events

    flash[:notice] = "#{successes} events copied, #{errors} errors (#{error_events.join(', ')})."
    redirect_to migrate_index_path
  end

  private

  def load_source_tenant
    @source_tenant = Tenant.find_by!(subdomain: params[:tenant])
  end

  def authorize_setup
    authorize @config, :setup_convention?
  end
end
