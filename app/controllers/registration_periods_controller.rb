class RegistrationPeriodsController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource

  # GET /registration_periods
  # GET /registration_periods.json
  def index
    @registration_periods = RegistrationPeriod.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @registration_periods }
    end
  end

  # GET /registration_periods/1
  # GET /registration_periods/1.json
  def show
    @registration_period = RegistrationPeriod.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @registration_period }
    end
  end

  # GET /registration_periods/new
  # GET /registration_periods/new.json
  def new
    @registration_period = RegistrationPeriod.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @registration_period }
    end
  end

  # GET /registration_periods/1/edit
  def edit
    @registration_period = RegistrationPeriod.find(params[:id])
  end

  # POST /registration_periods
  # POST /registration_periods.json
  def create
    @registration_period = RegistrationPeriod.new(params[:registration_period])

    respond_to do |format|
      if @registration_period.save
        format.html { redirect_to @registration_period, notice: 'Registration period was successfully created.' }
        format.json { render json: @registration_period, status: :created, location: @registration_period }
      else
        format.html { render action: "new" }
        format.json { render json: @registration_period.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /registration_periods/1
  # PUT /registration_periods/1.json
  def update
    @registration_period = RegistrationPeriod.find(params[:id])

    respond_to do |format|
      if @registration_period.update_attributes(params[:registration_period])
        format.html { redirect_to @registration_period, notice: 'Registration period was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @registration_period.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /registration_periods/1
  # DELETE /registration_periods/1.json
  def destroy
    @registration_period = RegistrationPeriod.find(params[:id])
    @registration_period.destroy

    respond_to do |format|
      format.html { redirect_to registration_periods_url }
      format.json { head :no_content }
    end
  end
end
