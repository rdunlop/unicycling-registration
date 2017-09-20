# == Schema Information
#
# Table name: heat_lane_results
#
#  id             :integer          not null, primary key
#  competition_id :integer          not null
#  heat           :integer          not null
#  lane           :integer          not null
#  status         :string           not null
#  minutes        :integer          not null
#  seconds        :integer          not null
#  thousands      :integer          not null
#  raw_data       :string
#  entered_at     :datetime         not null
#  entered_by_id  :integer          not null
#  created_at     :datetime
#  updated_at     :datetime
#

class HeatLaneResultsController < ApplicationController
  before_action :authenticate_user!
  before_action :load_heat_lane_result, except: [:create]

  before_action :authorize_competition_data

  before_action :set_breadcrumbs

  # DELETE /heat_lane_results/1
  # DELETE /heat_lane_results/1.json
  def destroy
    @heat_lane_result.destroy

    respond_to do |format|
      format.html { redirect_back(fallback_location: competition_heat_review_path(@competition, @heat_lane_result.heat)) }
      format.json { head :no_content }
    end
  end

  private

  def authorize_competition_data
    authorize @competition, :create_preliminary_result?
  end

  def load_heat_lane_result
    @heat_lane_result = HeatLaneResult.find(params[:id])
    @competition = @heat_lane_result.competition
  end

  def set_breadcrumbs
    add_to_competition_breadcrumb(@competition)
  end
end
