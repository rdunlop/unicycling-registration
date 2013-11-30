class RegistrationPeriodsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :load_new_registration_period, :only => [:create]
  load_and_authorize_resource

  def load_new_registration_period
    @registration_period = RegistrationPeriod.new(registration_period_params)
  end

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

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @registration_period }
    end
  end

  # GET /registration_periods/new
  # GET /registration_periods/new.json
  def new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @registration_period }
    end
  end

  # GET /registration_periods/1/edit
  def edit
  end

  # POST /registration_periods
  # POST /registration_periods.json
  def create

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

    respond_to do |format|
      if @registration_period.update_attributes(registration_period_params)
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
    @registration_period.destroy

    respond_to do |format|
      format.html { redirect_to registration_periods_url }
      format.json { head :no_content }
    end
  end

  private
  def registration_period_params
    params.require(:registration_period).permit(:competitor_expense_item_id, :end_date, :name, :noncompetitor_expense_item_id, :start_date, :onsite,
                                               :translations_attributes => [:id, :locale, :name])
  end
end
