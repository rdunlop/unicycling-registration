class EventConfigurationsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :load_new_event_configuration, :only => [:create]
  before_filter :load_event_configuration, except: :create
  load_and_authorize_resource

  def load_event_configuration
    @event_configuration = EventConfiguration.singleton
  end

  def load_new_event_configuration
    @event_configuration = EventConfiguration.new(event_configuration_params)
  end

  # GET /event_configurations
  # GET /event_configurations.json
  def index
    respond_to do |format|
      format.html # index.html.erb
    end
  end

  def update_base_settings
    @event_configuration.assign_attributes(base_settings_params)
    @event_configuration.apply_validation(:base_settings)
    respond_to do |format|
      if @event_configuration.save
        format.html { redirect_to base_settings_event_configurations_path, notice: 'Event configuration was successfully updated.' }
      else
        format.html { render action: "base_settings" }
      end
    end
  end

  def update_name_logo
    @event_configuration.assign_attributes(name_logo_params)
    @event_configuration.apply_validation(:name_logo)
    respond_to do |format|
      if @event_configuration.save
        format.html { redirect_to name_logo_event_configurations_path, notice: 'Event configuration was successfully updated.' }
      else
        format.html { render action: "name_logo" }
      end
    end
  end

  def update_important_dates
    @event_configuration.assign_attributes(important_dates_params)
    @event_configuration.apply_validation(:important_dates)
    respond_to do |format|
      if @event_configuration.save
        format.html { redirect_to important_dates_event_configurations_path, notice: 'Event configuration was successfully updated.' }
      else
        format.html { render action: "important_dates" }
      end
    end
  end

  def update_payment_settings
    @event_configuration.assign_attributes(payment_settings_params)
    @event_configuration.apply_validation(:payment_settings)
    respond_to do |format|
      if @event_configuration.save
        format.html { redirect_to payment_settings_event_configurations_path, notice: 'Event configuration was successfully updated.' }
      else
        format.html { render action: "payment_settings" }
      end
    end
  end

  # POST /event_configurations
  # POST /event_configurations.json
  def create
    respond_to do |format|
      if @event_configuration.save
        format.html { redirect_to event_configurations_path, notice: 'Event configuration was successfully created.' }
      else
        format.html { render action: "index" }
      end
    end
  end

  # PUT /event_configurations/1
  # PUT /event_configurations/1.json
  def update
    respond_to do |format|
      if @event_configuration.update_attributes(event_configuration_params)
        format.html { redirect_to event_configurations_path, notice: 'Event configuration was successfully updated.' }
      else
        format.html { render action: "index" }
      end
    end
  end

  # DELETE /event_configurations/1
  # DELETE /event_configurations/1.json
  def destroy
    @event_configuration.destroy

    respond_to do |format|
      format.html { redirect_to event_configurations_url }
      format.json { head :no_content }
    end
  end

  def cache
  end

  def clear_cache
    Rails.cache.clear
    flash[:notice] = "Cache cleared"
    redirect_to cache_event_configurations_path
  end

  def clear_counter_cache
    EventConfiguration.reset_counter_caches
    flash[:notice] = "Counter cache cleared"
    redirect_to cache_event_configurations_path
  end

  # FOR THE TEST_MODE flags
  def test_mode_role
    new_role = params[:role]
    roles = current_user.roles
    roles.each do |role|
      current_user.remove_role role.name if User.roles.include?(role.name.to_sym)
    end
    current_user.add_role new_role unless new_role.to_sym == :normal_user
    respond_to do |format|
      format.html { redirect_to :back, notice: 'User Permissions successfully updated.' }
    end
  end

  private

  def base_settings_params
    params.require(:event_configuration).permit(:spectators, :standard_skill, :standard_skill_closed_date, :style_name,
      :comp_noncomp_url, :usa_individual_expense_item_id, :usa_family_expense_item_id,
      :waiver, :waiver_url, :custom_waiver_text,
      :contact_email,
      :artistic_score_elimination_mode_naucc,
      :rulebook_url
      )
  end

  def name_logo_params
    params.require(:event_configuration).permit(:long_name, :short_name, :logo_file, :dates_description,
      :start_date, :event_url, :location,
      :translations_attributes => [:id, :locale, :short_name, :long_name, :location, :dates_description])
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

  def event_configuration_params
    params.require(:event_configuration).permit(:artistic_closed_date, :music_submission_end_date, :artistic_score_elimination_mode_naucc,
                                                :contact_email, :currency, :currency_code, :dates_description, :event_url, :iuf, :location,
                                                :logo_file, :max_award_place,
                                                :long_name, :rulebook_url, :short_name, :standard_skill, :standard_skill_closed_date, :style_name,
                                                :start_date, :event_sign_up_closed_date, :test_mode, :usa, :waiver, :waiver_url,
                                                :display_confirmed_events, :spectators, :paypal_account, :paypal_test,
                                                :custom_waiver_text, :comp_noncomp_url, :usa_individual_expense_item_id, :usa_family_expense_item_id,
                                                :translations_attributes => [:id, :locale, :short_name, :long_name, :location, :dates_description])
  end
end
