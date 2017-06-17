class ConventionSetup::RegistrationCostsController < ConventionSetup::BaseConventionSetupController
  before_action :authorize_setup
  before_action :load_registration_cost, except: %i[index new create]
  before_action :load_available_registrant_types, except: [:index]

  before_action :set_breadcrumbs

  # GET /registration_costs
  # GET /registration_costs.json
  def index
    @registration_costs = RegistrationCost.all
  end

  # GET /registration_costs/new
  # GET /registration_costs/new.json
  def new
    @registration_cost = RegistrationCost.new
    add_breadcrumb "New Registration Cost"
    rce = @registration_cost.registration_cost_entries.build
    rce.build_expense_item
  end

  # GET /registration_costs/1/edit
  def edit
    add_breadcrumb "Edit Registration Cost"
  end

  # POST /registration_costs
  # POST /registration_costs.json
  def create
    @registration_cost = RegistrationCost.new(registration_cost_params)
    creator = CreatesRegistrationCost.new(@registration_cost)

    if creator.perform
      redirect_to registration_costs_path, notice: 'Registration cost was successfully created.'
    else
      render :new
    end
  end

  # PUT /registration_costs/1
  # PUT /registration_costs/1.json
  def update
    @registration_cost.assign_attributes(registration_cost_params)
    creator = CreatesRegistrationCost.new(@registration_cost)
    if creator.perform
      redirect_to registration_costs_path, notice: 'Registration cost was successfully updated.'
    else
      render action: "edit"
    end
  end

  # DELETE /registration_costs/1
  # DELETE /registration_costs/1.json
  def destroy
    unless @registration_cost.destroy
      flash[:alert] = "Unable to destroy Registration Cost"
    end

    respond_to do |format|
      format.html { redirect_to registration_costs_url }
      format.json { head :no_content }
    end
  end

  private

  def authorize_setup
    authorize @config, :setup_convention?
  end

  def load_registration_cost
    @registration_cost = RegistrationCost.find(params[:id])
  end

  def set_breadcrumbs
    add_breadcrumb "Registration Costs", registration_costs_path
  end

  def registration_cost_params
    params.require(:registration_cost).permit(
      :end_date, :name, :registrant_type, :start_date, :onsite,
      registration_cost_entries_attributes: [
        :id,
        :min_age,
        :max_age,
        :expense_item_id,
        :_destroy,
        expense_item_attributes: %i[id cost tax]
      ],
      translations_attributes: %i[id locale name]
    )
  end

  def load_available_registrant_types
    if @config.noncompetitors?
      @registrant_types = ["competitor", "noncompetitor"]
    else
      @registrant_types = ["competitor"]
    end
  end
end
