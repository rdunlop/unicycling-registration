class RegistrationPeriodsController < ConventionSetupController
  before_action :authenticate_user!
  load_and_authorize_resource

  before_action :set_breadcrumbs

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
    @registration_period.build_competitor_expense_item
    @registration_period.build_noncompetitor_expense_item
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
    creator = CreatesRegistrationPeriod.new(@registration_period)

    respond_to do |format|
      if creator.perform
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
    if !@registration_period.destroy
      flash[:alert] = "Unable to destroy Registration Period"
    end

    respond_to do |format|
      format.html { redirect_to registration_periods_url }
      format.json { head :no_content }
    end
  end

  private

  def set_breadcrumbs
    add_breadcrumb "Registration Costs", registration_periods_path
  end

  def registration_period_params
    params.require(:registration_period).permit(:competitor_expense_item_id, :end_date, :name, :noncompetitor_expense_item_id, :start_date, :onsite,
                                                translations_attributes: [:id, :locale, :name],
                                                competitor_expense_item_attributes: [:id, :cost, :tax_percentage],
                                                noncompetitor_expense_item_attributes: [:id, :cost, :tax_percentage]
                                                )
  end
end
