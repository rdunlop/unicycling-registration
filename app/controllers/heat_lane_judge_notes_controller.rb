class HeatLaneJudgeNotesController < ApplicationController
  before_action :authenticate_user!
  before_action :load_competition
  before_action :load_heat_lane_judge_note

  before_action :authorize_competition_data

  # PUT /competition/:id/heat_lane_judge_note/:id/merge
  def merge
    lane = @heat_lane_judge_note.lane
    if @heat_lane_judge_note.merge
      flash[:notice] = "Updated Time Result for Lane #{lane}"
      redirect_to :back
    else
      flash[:alert] = "Unable to update Time Result for Lane #{lane}. Check that it exists"
      redirect_to :back
    end
  end

  private

  def authorize_competition_data
    authorize @competition, :create_preliminary_result?
  end

  def load_heat_lane_judge_note
    @heat_lane_judge_note = HeatLaneJudgeNote.find(params[:id])
  end

  def load_competition
    @competition = Competition.find(params[:competition_id])
  end
end
