class ConventionSetup::Migrate::MigrationsController < ApplicationController
  before_action :load_source_tenant, except: :index
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
    Apartment::Tenant.switch @source_tenant.subdomain do
      @events = Event.all.includes(:event_categories, category: :translations, event_choices: :translations).load
      @categories = Category.all.includes(:translations).load
    end

    successes = 0
    errors = 0
    error_events = []

    @categories.each do |category|
      new_category = category.dup
      new_category.name = category.name
      new_category.save
    end

    @events.each do |event|
      new_event = event.dup
      new_event.category = Category.find_by(name: event.category.name)
      if new_event.save
        event.event_choices.each do |ec|
          new_ec = ec.dup
          new_ec.label = ec.label
          new_ec.tooltip = ec.tooltip
          new_event.event_choices << new_ec # this causes the save
        end

        event.event_choices.each do |ec|
          new_ec = new_event.event_choices.find { |search_ec| search_ec.label == ec.label }
          if ec.optional_if_event_choice_id.present?
            optional_ec = event.event_choices.find { |search_ec| search_ec.id == ec.optional_if_event_choice_id }
            new_ec.optional_if_event_choice = new_event.event_choices.find_by(label: optional_ec.label)
            new_ec.save
          end
          if ec.required_if_event_choice_id.present?
            required_ec = event.event_choices.find { |search_ec| search_ec.id == ec.required_if_event_choice_id }
            new_ec.required_if_event_choice = new_event.event_choices.find_by(label: required_ec.label)
            new_ec.save
          end
        end

        event.event_categories.each do |ec|
          new_event.event_categories << ec.dup # this causes the save
        end
        successes += 1
      else
        errors += 1
        error_events << event.name
      end
    end
    flash[:notice] = "#{successes} events copied, #{errors} errors (#{error_events.join(', ')})."
    redirect_to migrate_index_path
  end

  private

  def load_source_tenant
    @source_tenant = Tenant.find_by(subdomain: params[:tenant])
  end

  def authorize_setup
    authorize @config, :setup_convention?
  end
end
