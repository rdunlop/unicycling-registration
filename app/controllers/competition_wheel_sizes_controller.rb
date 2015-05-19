class CompetitionWheelSizesController < ApplicationController
  load_resource :registrant, find_by: :bib_number, except: :destroy
  authorize_resource :registrant, except: :destroy
  load_and_authorize_resource through: :registrant, except: :destroy
  load_and_authorize_resource only: :destroy
  before_action :authenticate_user!
  layout "minimal"

  respond_to :html

  # GET /registrants/#/competition_wheel_sizes
  def index
    @competition_wheel_size = CompetitionWheelSize.new
  end

  # POST /competition_wheel_sizes
  def create
    authorize! :create, @registrant
    if @competition_wheel_size.save
      redirect_to registrant_competition_wheel_sizes_path(@registrant), notice: 'successfully created.'
    else
      @competition_wheel_sizes = @registrant.competition_wheel_sizes
      render action: 'index'
    end
  end

  # DELETE /competition_wheel_sizes/1
  def destroy
    @registrant = @competition_wheel_size.registrant
    authorize! :update, @registrant
    @competition_wheel_size.destroy
    redirect_to registrant_competition_wheel_sizes_path(@registrant), notice: 'Override was successfully deleted.'
  end

  private

  def competition_wheel_size_params
    params.require(:competition_wheel_size).permit(:event_id, :wheel_size_id)
  end
end
