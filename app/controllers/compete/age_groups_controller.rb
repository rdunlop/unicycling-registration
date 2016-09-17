class Compete::AgeGroupsController < ApplicationController
  layout "competition_management"

  before_action :authenticate_user!
  before_action :load_competition
  before_action :set_parent_breadcrumbs

  respond_to :html

  # GET /competitions/1/age_groups
  def show
    add_breadcrumb "Age Groups"
    @age_group_type = @competition.age_group_type

    respond_to do |format|
      format.html
      format.pdf { render_common_pdf("show") }
    end
  end

  def combine
    flash[:notice] = "Age Group Entry X and Y combined"
    redirect_to competition_age_groups_path(@competition)
  end

  private

  def load_competition
    @competition = Competition.find(params[:competition_id])
    authorize @competition, :manage_age_group?
  end

  def set_parent_breadcrumbs
    add_breadcrumb @competition.to_s, competition_path(@competition)
    add_breadcrumb "Manage Competitors", competition_competitors_path(@competition)
  end
end
