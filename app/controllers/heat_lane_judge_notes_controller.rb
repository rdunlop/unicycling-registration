# == Schema Information
#
# Table name: heat_lane_judge_notes
#
#  id             :integer          not null, primary key
#  competition_id :integer          not null
#  heat           :integer          not null
#  lane           :integer          not null
#  status         :string           not null
#  comments       :string
#  entered_at     :datetime         not null
#  entered_by_id  :integer          not null
#  created_at     :datetime
#  updated_at     :datetime
#
# Indexes
#
#  index_heat_lane_judge_notes_on_competition_id  (competition_id)
#

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
    else
      flash[:alert] = "Unable to update Time Result for Lane #{lane}. Check that it exists"
    end
    redirect_back(fallback_location: competition_heat_review_path(@competition, @heat_lane_judge_note.heat))
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
