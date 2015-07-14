class CompetitionWheelSizesController < ApplicationController
  before_action :authenticate_user!
  before_action :load_registrant_by_bib_number
  before_action :authorize_registrant

  layout "minimal"

  respond_to :html

  # GET /registrants/#/competition_wheel_sizes
  def index
    @competition_wheel_sizes = @registrant.competition_wheel_sizes
    @competition_wheel_size = CompetitionWheelSize.new
  end

  # POST /registrants/#/competition_wheel_sizes
  def create
    @competition_wheel_size = @registrant.competition_wheel_sizes.build(competition_wheel_size_params)
    if @competition_wheel_size.save
      redirect_to registrant_competition_wheel_sizes_path(@registrant), notice: 'successfully created.'
    else
      @competition_wheel_sizes = @registrant.competition_wheel_sizes
      render action: 'index'
    end
  end

  # DELETE /registrants/#/competition_wheel_sizes/1
  def destroy
    @competition_wheel_sizes = @registrant.competition_wheel_sizes.find(params[:id])
    @competition_wheel_size.destroy
    redirect_to registrant_competition_wheel_sizes_path(@registrant), notice: 'Override was successfully deleted.'
  end

  private

  def load_registrant_by_bib_number
    @registrant = Registrant.find_by(bib_number: params[:registrant_id])
  end

  def authorize_registrant
    authorize @registrant, :update?
  end

  def competition_wheel_size_params
    params.require(:competition_wheel_size).permit(:event_id, :wheel_size_id)
  end
end
