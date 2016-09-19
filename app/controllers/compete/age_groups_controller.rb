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
    if params[:age_group_entry_ids].size < 2
      flash[:alert] = "Must choose at least 2 age groups"
    else
      combiner = AgeGroupEntryCombiner.new(params[:age_group_entry_ids][0], params[:age_group_entry_ids][1])

      if combiner.combine
        flash[:notice] = "Combined 2 entries"
      else
        flash[:alert] = combiner.error_message
      end
    end
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
