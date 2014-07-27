class EventConfigurationsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :load_event_configuration, :only => [:create]
  load_and_authorize_resource


  def load_event_configuration
    @event_configuration = EventConfiguration.new(event_configuration_params)
  end

  # GET /event_configurations
  # GET /event_configurations.json
  def index
    @event_configurations = EventConfiguration.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @event_configurations }
    end
  end

  # GET /event_configurations/new
  # GET /event_configurations/new.json
  def new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @event_configuration }
    end
  end

  # GET /event_configurations/1/edit
  def edit
  end

  # POST /event_configurations
  # POST /event_configurations.json
  def create

    respond_to do |format|
      if @event_configuration.save
        format.html { redirect_to event_configurations_path, notice: 'Event configuration was successfully created.' }
        format.json { render json: @event_configuration, status: :created, location: @event_configuration }
      else
        format.html { render action: "new" }
        format.json { render json: @event_configuration.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /event_configurations/1
  # PUT /event_configurations/1.json
  def update

    respond_to do |format|
      if @event_configuration.update_attributes(event_configuration_params)
        format.html { redirect_to event_configurations_path, notice: 'Event configuration was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @event_configuration.errors, status: :unprocessable_entity }
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
  def event_configuration_params
    params.require(:event_configuration).permit(:artistic_closed_date, :music_submission_end_date, :artistic_score_elimination_mode_naucc,
                                                :contact_email, :currency, :currency_code, :dates_description, :event_url, :iuf, :location,
                                                :logo_file, :max_award_place,
                                                :long_name, :rulebook_url, :short_name, :standard_skill, :standard_skill_closed_date, :style_name,
                                                :start_date, :tshirt_closed_date, :test_mode, :usa, :has_print_waiver, :waiver_url, :has_online_waiver,
                                                :display_confirmed_events,
                                                :online_waiver_text, :comp_noncomp_url, :usa_individual_expense_item_id, :usa_family_expense_item_id,
                                                :translations_attributes => [:id, :locale, :short_name, :long_name, :location, :dates_description])
  end
end
