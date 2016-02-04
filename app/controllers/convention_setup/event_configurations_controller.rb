# == Schema Information
#
# Table name: event_configurations
#
#  id                                    :integer          not null, primary key
#  event_url                             :string(255)
#  start_date                            :date
#  contact_email                         :string(255)
#  artistic_closed_date                  :date
#  standard_skill_closed_date            :date
#  event_sign_up_closed_date             :date
#  created_at                            :datetime
#  updated_at                            :datetime
#  test_mode                             :boolean          default(FALSE), not null
#  comp_noncomp_url                      :string(255)
#  standard_skill                        :boolean          default(FALSE), not null
#  usa                                   :boolean          default(FALSE), not null
#  iuf                                   :boolean          default(FALSE), not null
#  currency_code                         :string(255)
#  rulebook_url                          :string(255)
#  style_name                            :string(255)
#  custom_waiver_text                    :text
#  music_submission_end_date             :date
#  artistic_score_elimination_mode_naucc :boolean          default(TRUE), not null
#  usa_individual_expense_item_id        :integer
#  usa_family_expense_item_id            :integer
#  logo_file                             :string(255)
#  max_award_place                       :integer          default(5)
#  display_confirmed_events              :boolean          default(FALSE), not null
#  spectators                            :boolean          default(FALSE), not null
#  usa_membership_config                 :boolean          default(FALSE), not null
#  paypal_account                        :string(255)
#  waiver                                :string(255)      default("none")
#  validations_applied                   :integer
#  italian_requirements                  :boolean          default(FALSE), not null
#  rules_file_name                       :string(255)
#  accept_rules                          :boolean          default(FALSE), not null
#  paypal_mode                           :string(255)      default("disabled")
#  offline_payment                       :boolean          default(FALSE), not null
#  enabled_locales                       :string           default("en,fr"), not null
#  comp_noncomp_page_id                  :integer
#  under_construction                    :boolean          default(TRUE), not null
#

class ConventionSetup::EventConfigurationsController < ConventionSetup::BaseConventionSetupController
  before_action :authenticate_user!
  before_action :load_event_configuration
  before_action :authorize_cache, only: [:cache, :clear_cache, :clear_counter_cache]

  EVENT_CONFIG_PAGES = [:registrant_types, :rules_waiver, :name_logo, :important_dates, :volunteers, :payment_settings, :advanced_settings, :go_live]

  before_action :authorize_convention_setup, only: EVENT_CONFIG_PAGES

  EVENT_CONFIG_PAGES.each do |page|
    define_method("update_#{page}") do
      authorize_convention_setup
      update(page)
    end
    before_action "set_#{page}_breadcrumbs".to_sym, only: ["update_#{page}".to_sym, "#{page}".to_sym]
    define_method("set_#{page}_breadcrumbs") do
      add_breadcrumb page.to_s.humanize
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
    authorize @event_configuration
    role = params[:role]

    if User.changable_user_roles.include?(role.to_sym)
      if current_user.has_role? role
        current_user.remove_role role
      else
        current_user.add_role role
      end

      redirect_to :back, notice: 'User Permissions successfully updated.'
    else
      redirect_to :back, alert: "Unable to set role"
    end
  end

  private

  def authorize_cache
    authorize @event_configuration, :manage_cache?
  end

  def authorize_convention_setup
    authorize @event_configuration, :setup_convention?
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

  def load_event_configuration
    @event_configuration = EventConfiguration.singleton
  end

  def registrant_types_params
    params.require(:event_configuration).permit(:spectators, :noncompetitors,
                                                :competitor_benefits, :noncompetitor_benefits, :spectator_benefits,
                                                :comp_noncomp_url, :comp_noncomp_page_id)
  end

  def rules_waiver_params
    params.require(:event_configuration).permit(:waiver, :waiver_url, :custom_waiver_text,
                                                :accept_rules, :rules_file_name,
                                                :rulebook_url)
  end

  def volunteers_params
    params.require(:event_configuration).permit(:volunteer_option)
  end

  def advanced_settings_params
    params.require(:event_configuration).permit(:standard_skill, :standard_skill_closed_date,
                                                :usa_membership_config,
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
                                                :start_date, :age_calculation_base_date)
  end

  def go_live_params
    params.require(:event_configuration).permit(:under_construction)
  end
end
