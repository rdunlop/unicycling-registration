class EventConfigurationsController < ApplicationController
  before_filter :authenticate_user!, :except => [:logo]
  load_and_authorize_resource


  # GET /event_configurations/1/logo
  def logo
    @event_configuration = EventConfiguration.find(params[:id])
    @image = @event_configuration.logo_binary
    send_data @image, :type => @event_configuration.logo_type,
               :filename => @event_configuration.logo_filename,
               :disposition => 'inline'
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

  # GET /event_configurations/1
  # GET /event_configurations/1.json
  def show
    @event_configuration = EventConfiguration.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @event_configuration }
    end
  end

  # GET /event_configurations/new
  # GET /event_configurations/new.json
  def new
    @event_configuration = EventConfiguration.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @event_configuration }
    end
  end

  # GET /event_configurations/1/edit
  def edit
    @event_configuration = EventConfiguration.find(params[:id])
  end

  # POST /event_configurations
  # POST /event_configurations.json
  def create
    @event_configuration = EventConfiguration.new(params[:event_configuration])

    respond_to do |format|
      if @event_configuration.save
        format.html { redirect_to @event_configuration, notice: 'Event configuration was successfully created.' }
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
    @event_configuration = EventConfiguration.find(params[:id])

    respond_to do |format|
      if @event_configuration.update_attributes(params[:event_configuration])
        format.html { redirect_to @event_configuration, notice: 'Event configuration was successfully updated.' }
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
    @event_configuration = EventConfiguration.find(params[:id])
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
end
