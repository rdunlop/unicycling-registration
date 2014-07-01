class CompetitionWheelSizesController < ApplicationController
  before_filter :authenticate_user!

  load_and_authorize_resource

  respond_to :html

  # GET /competition_wheel_sizes
  def index
    @competition_wheel_sizes= CompetitionWheelSize.all
  end

  # GET /competition_wheel_sizes/new
  def new
    @competition_wheel_size = CompetitionWheelSize.new
  end

  # GET /competition_wheel_sizes/1/edit
  def edit
  end

  # POST /competition_wheel_sizes
  def create
    if @competition_wheel_size.save
      redirect_to competition_wheel_sizes_path, notice: 'successfully created.'
    else
      render action: 'new'
    end
  end

  # PATCH/PUT /competition_wheel_sizes/1
  def update
    if @competition_wheel_size.update(competition_wheel_size_params)
      redirect_to competition_wheel_sizes_path, notice: 'successfully update.'
    else
      render action: 'edit'
    end
  end

  # DELETE /competition_wheel_sizes/1
  def destroy
    @competition_wheel_size.destroy
    redirect_to competition_wheel_sizes_path, notice: 'Combined competition entry was successfully destroyed.'
  end

  private

    # Only allow a trusted parameter "white list" through.
    def competition_wheel_size_params
      params.require(:competition_wheel_size).permit(:registrant_id, :event_id, :wheel_size_id)
    end
end
