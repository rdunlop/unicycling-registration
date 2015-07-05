class Compete::WaveTimesController < ApplicationController
  layout "competition_management"
  before_action :authenticate_user!

  load_resource :competition
  load_and_authorize_resource :wave_time, through: :competition

  before_action :set_parent_breadcrumbs

  respond_to :html

  # GET /competitions/1/wave_times
  def index
    @wave_times = @competition.wave_times
    @wave_time = WaveTime.new
  end

  def create
    @wave_time.competition = @competition
    if @wave_time.save
      flash[:notice] = "Wave Time Created"
      redirect_to competition_wave_times_path(@competition)
    else
      flash[:alert] = "Unable to create Wave Time"
      @wave_times = @competition.wave_times
      render :index
    end
  end

  def edit
  end

  def update
    if @wave_time.update_attributes(wave_time_params)
      flash[:notice] = "Wave Time Updated"
      redirect_to competition_wave_times_path(@competition)
    else
      @wave_times = @competition.wave_times
      render :index
    end
  end

  def destroy
    if @wave_time.destroy
      flash[:notice] = "Wave Time Deleted"
    else
      flash[:alert] = "Unable to delete Wave time"
    end

    redirect_to competition_wave_times_path(@competition)
  end

  private

  def wave_time_params
    params.require(:wave_time).permit(:id, :scheduled_time, :wave, :minutes, :seconds)
  end

  def set_parent_breadcrumbs
    add_breadcrumb "#{@competition}", competition_path(@competition)
  end
end
