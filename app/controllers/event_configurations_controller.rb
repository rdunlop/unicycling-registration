class EventConfigurationsController < ApplicationController
  before_filter :authenticate_user!, :except => [:logo]
  before_filter :load_event_configuration, :only => [:create]
  load_and_authorize_resource


  def load_event_configuration
    @event_configuration = EventConfiguration.new(event_configuration_params)
  end

  # GET /event_configurations/1/logo
  def logo
    @event_configuration = EventConfiguration.find(params[:id])
    @image = @event_configuration.logo_binary

    if @event_configuration.logo_type.nil?
      render nothing: true
    else
      send_data @image, :type => @event_configuration.logo_type,
        :filename => @event_configuration.logo_filename,
        :disposition => 'inline'
    end
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
  def admin
    current_user.add_role :admin
    current_user.remove_role :super_admin

    respond_to do |format|
      format.html { redirect_to root_path, notice: 'User Permissions successfully updated.' }
    end
  end

  def super_admin
    current_user.remove_role :admin
    current_user.add_role :super_admin

    respond_to do |format|
      format.html { redirect_to root_path, notice: 'User Permissions successfully updated.' }
    end
  end

  def normal
    current_user.remove_role :super_admin
    current_user.remove_role :admin

    respond_to do |format|
      format.html { redirect_to root_path, notice: 'User Permissions successfully updated.' }
    end
  end

  private
  def event_configuration_params
    params.require(:event_configuration).permit(:artistic_closed_date, :contact_email, :currency, :currency_code, :dates_description, :event_url, :iuf, :location, :logo_image,
                                                :long_name, :rulebook_url, :short_name, :standard_skill, :standard_skill_closed_date, :style_name,
                                                :start_date, :tshirt_closed_date, :test_mode, :usa, :has_print_waiver, :waiver_url, :has_online_waiver, :online_waiver_text, :comp_noncomp_url,
                                                :translations_attributes => [:id, :locale, :short_name, :long_name, :location, :dates_description])
  end
end
