class Translations::RegistrationCostsController < Admin::TranslationsController
  before_action :load_registration_cost, except: :index

  def index
    @registration_costs = RegistrationCost.all
  end

  # GET /translations/registration_costs/1/edit
  def edit
  end

  # PUT /translations/registration_costs/1
  def update
    if @registration_cost.update_attributes(registration_cost_params)
      flash[:notice] = 'Registration Costs was successfully updated.'
      redirect_to action: :index
    else
      render :edit
    end
  end

  private

  def load_registration_cost
    @registration_cost = RegistrationCost.find(params[:id])
  end

  def registration_cost_params
    params.require(:registration_cost).permit(translations_attributes: [:id, :locale, :name])
  end
end
