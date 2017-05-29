class Compete::TierAssignmentsController < ApplicationController
  layout "competition_management"

  before_action :authenticate_user!
  before_action :load_competition
  before_action :set_parent_breadcrumbs

  respond_to :html

  # GET /competitions/1/tier_assignments
  def show
    authorize @competition, :assign_tiers?
    add_breadcrumb "Current Tiers"
    @competitors = @competition.competitors
    respond_to do |format|
      format.html {}
    end
  end

  # PUT /competitions/1/tier_assignments
  def update
    authorize @competition, :assign_tiers?

    if @competition.update_attributes(update_competitors_params)
      flash[:notice] = "updated competitor tiers/descriptions"
    else
      flash[:alert] = "Unable to update tier assignments"
    end

    redirect_to competition_tier_assignments_path(@competition)
  end

  private

  def load_competition
    @competition = Competition.find(params[:competition_id])
  end

  def set_parent_breadcrumbs
    add_breadcrumb @competition.to_s, competition_path(@competition)
  end

  def update_competitors_params
    params.require(:competition).permit(competitors_attributes: %i[id tier_number tier_description])
  end
end
