class ConventionSetup::RegistrationCostsController < ConventionSetup::BaseConventionSetupController
  before_action :authorize_setup
  before_action :load_registration_cost, except: [:index, :new, :create]
  before_action :load_available_registrant_types, except: [:index]

  before_action :set_breadcrumbs

  # GET /registration_costs
  # GET /registration_costs.json
  def index
    @registration_costs = RegistrationCost.all

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  # GET /registration_costs/new
  # GET /registration_costs/new.json
  def new
    @registration_cost = RegistrationCost.new
    add_breadcrumb "New Registration Cost"
    @registration_cost.build_expense_item
    respond_to do |format|
      format.html # new.html.erb
    end
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

    respond_to do |format|
      if creator.perform
        format.html { redirect_to registration_costs_path, notice: 'Registration cost was successfully created.' }
      else
        format.html { render action: "new" }
      end
    end
  end

  # PUT /registration_costs/1
  # PUT /registration_costs/1.json
  def update
    respond_to do |format|
      if @registration_cost.update_attributes(registration_cost_params)
        format.html { redirect_to registration_costs_path, notice: 'Registration cost was successfully updated.' }
      else
        format.html { render action: "edit" }
      end
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
      :expense_item_id, :end_date, :name, :registrant_type, :start_date, :onsite,
      translations_attributes: [:id, :locale, :name],
      expense_item_attributes: [:id, :cost, :tax]
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
