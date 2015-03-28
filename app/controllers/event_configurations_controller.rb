class EventConfigurationsController < ConventionSetupController
  before_action :authenticate_user!
  before_action :load_event_configuration
  before_action :set_base_settings_breadcrumb, only: [:update_base_settings, :base_settings]
  before_action :set_name_logo_breadcrumb, only: [:update_name_logo, :name_logo]
  before_action :set_important_dates_breadcrumb, only: [:update_important_dates, :important_dates]
  before_action :set_payment_settings_breadcrumb, only: [:update_payment_settings, :payment_settings]

  load_and_authorize_resource

  def update_base_settings
    @event_configuration.assign_attributes(base_settings_params)
    @event_configuration.apply_validation(:base_settings)
    if @event_configuration.save
      redirect_to base_settings_event_configuration_path, notice: 'Event configuration was successfully updated.'
    else
      render action: "base_settings"
    end
  end

  def update_name_logo
    @event_configuration.assign_attributes(name_logo_params)
    @event_configuration.apply_validation(:name_logo)
    if @event_configuration.save
      redirect_to name_logo_event_configuration_path, notice: 'Event configuration was successfully updated.'
    else
      render action: "name_logo"
    end
  end

  def update_important_dates
    @event_configuration.assign_attributes(important_dates_params)
    @event_configuration.apply_validation(:important_dates)
    if @event_configuration.save
      redirect_to important_dates_event_configuration_path, notice: 'Event configuration was successfully updated.'
    else
      render action: "important_dates"
    end
  end

  def update_payment_settings
    @event_configuration.assign_attributes(payment_settings_params)
    @event_configuration.apply_validation(:payment_settings)
    if @event_configuration.save
      redirect_to payment_settings_event_configuration_path, notice: 'Event configuration was successfully updated.'
    else
      render action: "payment_settings"
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

  def base_settings_params
    params.require(:event_configuration).permit(:spectators, :standard_skill, :standard_skill_closed_date, :style_name,
                                                :comp_noncomp_url, :usa_individual_expense_item_id, :usa_family_expense_item_id,
                                                :waiver, :waiver_url, :custom_waiver_text,
                                                :italian_requirements,
                                                :accept_rules, :rules_file_name,
                                                :contact_email,
                                                :artistic_score_elimination_mode_naucc,
                                                :rulebook_url
      )
  end

  def name_logo_params
    params.require(:event_configuration).permit(:long_name, :short_name, :logo_file, :dates_description,
                                                :start_date, :event_url, :location,
                                                translations_attributes: [
                                                  :id, :locale, :short_name, :long_name, :location, :dates_description,
                                                  :competitor_benefits, :noncompetitor_benefits, :spectator_benefits])
  end

  def payment_settings_params
    params.require(:event_configuration).permit(:paypal_account, :paypal_test,
                                                :currency, :currency_code)
  end

  def important_dates_params
    params.require(:event_configuration).permit(:artistic_closed_date, :music_submission_end_date, :event_sign_up_closed_date,
                                                :iuf,
                                                :max_award_place,
                                                :test_mode, :usa,
                                                :display_confirmed_events)
  end
end
