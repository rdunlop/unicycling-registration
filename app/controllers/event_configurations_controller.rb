class EventConfigurationsController < ConventionSetupController
  before_action :authenticate_user!
  before_action :load_event_configuration

  load_and_authorize_resource

  EVENT_CONFIG_PAGES = [:registrant_types, :rules_waiver, :name_logo, :important_dates, :payment_settings, :advanced_settings]

  EVENT_CONFIG_PAGES.each do |page|
    define_method("update_#{page}") do
      update(page)
    end
    before_action "set_#{page}_breadcrumbs".to_sym, only: ["update_#{page}".to_sym, "#{page}".to_sym]
    define_method("set_#{page}_breadcrumbs") do
      add_breadcrumb page.to_s.humanize
    end
  end

  def update(page)
    @event_configuration.assign_attributes(send("#{page}_params"))
    @event_configuration.apply_validation(page)
    if @event_configuration.save
      redirect_to convention_setup_path, notice: 'Event configuration was successfully updated.'
    else
      render action: page
    end
  end

  def cache
  end

  def clear_cache
    Rails.cache.clear
    flash[:notice] = "Cache cleared"
    redirect_to cache_event_configuration_path
  end

  def clear_counter_cache
    EventConfiguration.reset_counter_caches
    flash[:notice] = "Counter cache cleared"
    redirect_to cache_event_configuration_path
  end

  # Toggle a role for the current user
  # Only enabled when the TEST_MODE flag is set
  def test_mode_role
    role = params[:role]

    if current_user.has_role? role
      current_user.remove_role role
    else
      current_user.add_role role
    end

    redirect_to :back, notice: 'User Permissions successfully updated.'
  end

  private

  def load_event_configuration
    @event_configuration = EventConfiguration.singleton
  end

  def registrant_types_params
    params.require(:event_configuration).permit(:spectators,
                                                :competitor_benefits, :noncompetitor_benefits, :spectator_benefits,
                                                :comp_noncomp_url)
  end

  def rules_waiver_params
    params.require(:event_configuration).permit(:waiver, :waiver_url, :custom_waiver_text,
                                                :accept_rules, :rules_file_name,
                                                :rulebook_url)
  end

  def advanced_settings_params
    params.require(:event_configuration).permit(:standard_skill, :standard_skill_closed_date,
                                                :usa_individual_expense_item_id, :usa_family_expense_item_id,
                                                :italian_requirements,
                                                :iuf,
                                                :test_mode, :usa,
                                                :display_confirmed_events,
                                                enabled_locales: []
                                               )
  end

  def name_logo_params
    params.require(:event_configuration).permit(:long_name, :short_name, :logo_file, :dates_description,
                                                :event_url, :location, :contact_email, :style_name)
  end

  def payment_settings_params
    params.require(:event_configuration).permit(:paypal_account, :paypal_mode, :offline_payment, :offline_payment_description,
                                                :currency, :currency_code)
  end

  def important_dates_params
    params.require(:event_configuration).permit(:artistic_closed_date, :music_submission_end_date, :event_sign_up_closed_date,
                                                :start_date)
  end
end
