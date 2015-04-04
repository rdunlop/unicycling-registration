class EventConfigurationsController < ConventionSetupController
  before_action :authenticate_user!
  before_action :load_event_configuration
  before_action :set_base_settings_breadcrumb, only: [:update_base_settings, :base_settings]
  before_action :set_name_logo_breadcrumb, only: [:update_name_logo, :name_logo]
  before_action :set_important_dates_breadcrumb, only: [:update_important_dates, :important_dates]
  before_action :set_payment_settings_breadcrumb, only: [:update_payment_settings, :payment_settings]

  load_and_authorize_resource

  EVENT_CONFIG_PAGES = [:registrant_types, :rules_waiver, :name_logo, :important_dates, :payment_settings, :advanced_settings]

  EVENT_CONFIG_PAGES.each do |page|
    define_method("update_#{page}") do
      update(page)
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

  # FOR THE TEST_MODE flags
  def test_mode_role
    new_role = params[:role]
    roles = current_user.roles
    roles.each do |role|
      current_user.remove_role role.name if User.roles.include?(role.name.to_sym)
    end
    current_user.add_role new_role unless new_role.to_sym == :normal_user

    redirect_to :back, notice: 'User Permissions successfully updated.'
  end

  private

  def set_base_settings_breadcrumb
    add_breadcrumb "Base Settings", base_settings_event_configuration_path
  end

  def set_name_logo_breadcrumb
    add_breadcrumb "Name and Logo", name_logo_event_configuration_path
  end

  def set_payment_settings_breadcrumb
    add_breadcrumb "Payment Settings", payment_settings_event_configuration_path
  end

  def set_important_dates_breadcrumb
    add_breadcrumb "Important Deadlines", important_dates_event_configuration_path
  end

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
                                                :start_date,
                                                :iuf,
                                                :test_mode, :usa,
                                                :display_confirmed_events)
  end
end
