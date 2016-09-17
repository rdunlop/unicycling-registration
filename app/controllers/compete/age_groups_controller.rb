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
      age_group_entries = @competition.age_group_type.age_group_entries_by_age_gender.where(id: params[:age_group_entry_ids])
      smallest_age_group_entry = age_group_entries.first

      remaining_entries = age_group_entries - [smallest_age_group_entry]

      max_age = smallest_age_group_entry.end_age
      remaining_entries.each do |ag_entry|
        if ag_entry.gender != smallest_age_group_entry.gender
          flash[:alert] = "Age Group Entries must be the same gender"
          redirect_to competition_age_groups_path(@competition)
          return
        end
        if ag_entry.start_age != max_age + 1
          flash[:alert] = "Age Group Entries must be contiguous"
          redirect_to competition_age_groups_path(@competition)
          return
        end
        max_age = ag_entry.end_age
      end

      AgeGroupEntry.transaction do
        smallest_age_group_entry.end_age = max_age
        smallest_age_group_entry.short_description = "#{smallest_age_group_entry.start_age} - #{smallest_age_group_entry.end_age} #{smallest_age_group_entry.gender}"
        smallest_age_group_entry.save!
        remaining_entries.each(&:destroy!)
      end
      flash[:notice] = "Combined #{remaining_entries.count} entries into #{smallest_age_group_entry}"
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
