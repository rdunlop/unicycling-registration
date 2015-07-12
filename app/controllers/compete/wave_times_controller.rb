class Compete::WaveTimesController < ApplicationController
  layout "competition_management"

  before_action :load_competition
  before_action :authorize_data_entry, except: [:index]

  before_action :load_wave_time, only: [:edit, :update, :destroy]

  before_action :set_parent_breadcrumbs

  respond_to :html

  # GET /competitions/1/wave_times
  def index
    authorize @competition, :view_result_data?
    @wave_times = @competition.wave_times
    @wave_time = WaveTime.new
  end

  def create
    @wave_time = @competition.wave_times.build(wave_time_params)

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

  def authorize_data_entry
    authorize @competition, :modify_result_data?
  end

  def load_competition
    @competition = Competition.find(params[:competition_id])
  end

  def load_wave_time
    @wave_time = @competition.wave_times.find(params[:id])
  end

  def wave_time_params
    params.require(:wave_time).permit(:id, :scheduled_time, :wave, :minutes, :seconds)
  end

  def set_parent_breadcrumbs
    add_breadcrumb "#{@competition}", competition_path(@competition)
  end
end
