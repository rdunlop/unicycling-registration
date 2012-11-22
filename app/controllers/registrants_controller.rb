class RegistrantsController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource

  # GET /registrants
  # GET /registrants.json
  def index
    @registrants = Registrant.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @registrants }
    end
  end

  # GET /registrants/1
  # GET /registrants/1.json
  def show
    @registrant = Registrant.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @registrant }
    end
  end

  # GET /registrants/new
  # GET /registrants/new.json
  def new
    @registrant = Registrant.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @registrant }
    end
  end

  # GET /registrants/1/edit
  def edit
    @registrant = Registrant.find(params[:id])
  end

  # POST /registrants
  # POST /registrants.json
  def create
    @registrant = Registrant.new(params[:registrant])

    respond_to do |format|
      if @registrant.save
        format.html { redirect_to new_attending_path(@registrant), notice: 'Registrant was successfully created.' }
        format.json { render json: @registrant, status: :created, location: @registrant }
      else
        format.html { render action: "new" }
        format.json { render json: @registrant.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /registrants/1
  # PUT /registrants/1.json
  def update
    @registrant = Registrant.find(params[:id])

    respond_to do |format|
      if @registrant.update_attributes(params[:registrant])
        format.html { redirect_to new_attending_path(@registrant), notice: 'Registrant was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @registrant.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /registrants/1
  # DELETE /registrants/1.json
  def destroy
    @registrant = Registrant.find(params[:id])
    @registrant.destroy

    respond_to do |format|
      format.html { redirect_to registrants_url }
      format.json { head :no_content }
    end
  end
end
