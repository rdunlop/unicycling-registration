class CombinedCompetitionEntriesController < ApplicationController
  before_filter :authenticate_user!

  before_action :load_combined_competition
  before_action :set_combined_competition_entry, only: [:edit, :update, :destroy]

  load_and_authorize_resource

  respond_to :html

  # GET /combined_competition_entries
  def index
    @combined_competition_entries = @combined_competition.combined_competition_entries
  end

  # GET /combined_competition_entries/new
  def new
    @combined_competition_entry = CombinedCompetitionEntry.new
  end

  # GET /combined_competition_entries/1/edit
  def edit
  end

  # POST /combined_competition_entries
  def create
    @combined_competition_entry = @combined_competition.combined_competition_entries.build(combined_competition_entry_params)

    if @combined_competition_entry.save
      redirect_to combined_competition_combined_competition_entries_path(@combined_competition), notice: 'Combined competition entry was successfully created.'
    else
      render action: 'new'
    end
  end

  # PATCH/PUT /combined_competition_entries/1
  def update
    if @combined_competition_entry.update(combined_competition_entry_params)
      redirect_to combined_competition_combined_competition_entries_path(@combined_competition), notice: 'Combined competition entry was successfully updated.'
    else
      render action: 'edit'
    end
  end

  # DELETE /combined_competition_entries/1
  def destroy
    @combined_competition_entry.destroy
    redirect_to @combined_competition, notice: 'Combined competition entry was successfully destroyed.'
  end

  private

    # Use callbacks to share common setup or constraints between actions.
  def set_combined_competition_entry
    @combined_competition_entry = CombinedCompetitionEntry.find(params[:id])
  end

  def load_combined_competition
    @combined_competition = CombinedCompetition.find(params[:combined_competition_id])
  end

    # Only allow a trusted parameter "white list" through.
  def combined_competition_entry_params
    params.require(:combined_competition_entry).permit(:abbreviation, :tie_breaker, :base_points,
                                                       :points_1, :points_2, :points_3, :points_4, :points_5,
                                                       :points_6, :points_7, :points_8, :points_9, :points_10,
                                                       :competition_id)
  end
end
