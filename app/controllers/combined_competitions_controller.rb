class CombinedCompetitionsController < ApplicationController
  before_filter :authenticate_user!, except: :show

  before_action :set_combined_competition, only: [:show, :edit, :update, :destroy]

  load_and_authorize_resource

  respond_to :html

  # GET /combined_competitions
  def index
  end

  # GET /combined_competitions/1
  def show
  end

  # GET /combined_competitions/new
  def new
    @combined_competition = CombinedCompetition.new
  end

  # GET /combined_competitions/1/edit
  def edit
  end

  # POST /combined_competitions
  def create
    @combined_competition = CombinedCompetition.new(combined_competition_params)

    if @combined_competition.save
      redirect_to combined_competition_combined_competition_entries_path(@combined_competition), notice: 'Combined competition was successfully created.'
    else
      render action: 'new'
    end
  end

  # PATCH/PUT /combined_competitions/1
  def update
    if @combined_competition.update(combined_competition_params)
      redirect_to @combined_competition, notice: 'Combined competition was successfully updated.'
    else
      render action: 'edit'
    end
  end

  # DELETE /combined_competitions/1
  def destroy
    @combined_competition.destroy
    redirect_to combined_competitions_url, notice: 'Combined competition was successfully destroyed.'
  end

  private

    # Use callbacks to share common setup or constraints between actions.
    def set_combined_competition
      @combined_competition = CombinedCompetition.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def combined_competition_params
      params.require(:combined_competition).permit(:name, :use_age_group_places, :percentage_based_calculations)
    end
end
