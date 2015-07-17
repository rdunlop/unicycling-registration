class Translations::RegistrationPeriodsController < Admin::TranslationsController
  before_action :load_registration_period, except: :index

  def index
    @registration_periods = RegistrationPeriod.all
  end

  # GET /translations/registration_periods/1/edit
  def edit
  end

  # PUT /translations/registration_periods/1
  def update
    if @registration_period.update_attributes(registration_period_params)
      flash[:notice] = 'RegistrationPeriod was successfully updated.'
      redirect_to action: :index
    else
      render :edit
    end
  end

  private

  def load_registration_period
    @registration_period = RegistrationPeriod.find(params[:id])
  end

  def registration_period_params
    params.require(:registration_period).permit(translations_attributes: [:id, :locale, :name])
  end
end
