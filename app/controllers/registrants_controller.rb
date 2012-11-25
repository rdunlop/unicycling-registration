class RegistrantsController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource

  # GET /registrants
  # GET /registrants.json
  def index
    @registrants = current_user.registrants
    @total_owing = current_user.total_owing

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
    @registrant.competitor = true

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @registrant }
    end
  end

  def new_noncompetitor
    @registrant = Registrant.new
    @registrant.competitor = false

    respond_to do |format|
      format.html { render action: "new" } # new.html.erb
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
    @registrant.user = current_user

    respond_to do |format|
      if @registrant.save
        if @registrant.competitor # go to page 2
          format.html { redirect_to new_attending_path(@registrant), notice: 'Registrant was successfully created.' }
          format.json { render json: @registrant, status: :created, location: @registrant }
        else
          format.html { redirect_to @registrant, notice: 'Registrant was successfully created.' }
        end
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
        if @registrant.competitor
          format.html { redirect_to new_attending_path(@registrant), notice: 'Registrant was successfully updated.' }
          format.json { head :no_content }
        else
          format.html {redirect_to @registrant, notice: 'Registrant was successfully updated.' }
        end
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
