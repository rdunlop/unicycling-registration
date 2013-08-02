class RegistrantGroupsController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource

  # GET /registrant_groups
  # GET /registrant_groups.json
  def index
    @registrant_groups = RegistrantGroup.all
    @registrant_group = RegistrantGroup.new

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @registrant_groups }
    end
  end

  # GET /registrant_groups/1
  # GET /registrant_groups/1.json
  def show
    @registrant_group = RegistrantGroup.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @registrant_group }
    end
  end

  # GET /registrant_groups/1/edit
  def edit
    @registrant_group = RegistrantGroup.find(params[:id])
  end

  # POST /registrant_groups
  # POST /registrant_groups.json
  def create
    @registrant_group = RegistrantGroup.new(params[:registrant_group])

    respond_to do |format|
      if @registrant_group.save
        format.html { redirect_to @registrant_group, notice: 'Registrant group was successfully created.' }
        format.json { render json: @registrant_group, status: :created, location: @registrant_group }
      else
        format.html { render action: "index" }
        format.json { render json: @registrant_group.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /registrant_groups/1
  # PUT /registrant_groups/1.json
  def update
    @registrant_group = RegistrantGroup.find(params[:id])

    respond_to do |format|
      if @registrant_group.update_attributes(params[:registrant_group])
        format.html { redirect_to @registrant_group, notice: 'Registrant group was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @registrant_group.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /registrant_groups/1
  # DELETE /registrant_groups/1.json
  def destroy
    @registrant_group = RegistrantGroup.find(params[:id])
    @registrant_group.destroy

    respond_to do |format|
      format.html { redirect_to registrant_groups_url }
      format.json { head :no_content }
    end
  end
end
