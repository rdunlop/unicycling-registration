# == Schema Information
#
# Table name: results
#
#  id             :integer          not null, primary key
#  competitor_id  :integer
#  result_type    :string(255)
#  result_subtype :integer
#  place          :integer
#  status         :string(255)
#  created_at     :datetime
#  updated_at     :datetime
#
# Indexes
#
#  index_results_on_competitor_id_and_result_type  (competitor_id,result_type) UNIQUE
#

class ResultsController < ApplicationController
  before_action :skip_authorization

  def index
    add_breadcrumb "Results"

    respond_to do |format|
      format.html
    end
  end

  # GET /results/registrant?registrant_id=123
  def registrant
    registrant = Registrant.find_by(id: params[:registrant_id])
    if registrant.present?
      redirect_to results_registrant_path(registrant)
    else
      flash[:alert] = "Registrant not found"
      render :index
    end
  end

  # Display the CombinedCompetition preliminary scores
  def scores
    @competition = Competition.find(params[:id])
    @combined_competition = @competition.combined_competition
    redirect_to root_url, alert: "competition has no viewable scores" if @combined_competition.nil?
  end

  # Display the current results for HighJump/LongJump
  def distances
    @competition = Competition.find(params[:id])
    redirect_to root_url, alert: "competition has no viewable scores" unless @competition.high_long_event?
  end
end
