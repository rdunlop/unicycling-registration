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

  # PUT /competitions/1/age_groups/combine?age_groups[]=entry-1&age_groups[]=combination-2
  def combine
    first_age_group, second_age_group = Array(params[:age_groups]).first(2).map { |param| @competition.find_age_group(param) }

    combiner = AgeGroupCombiner.new(@competition)
    if combiner.combine(first_age_group, second_age_group)
      flash[:notice] = "Combined #{first_age_group} with #{second_age_group}"
    else
      flash[:alert] = combiner.error_message
    end
    redirect_to competition_age_groups_path(@competition)
  end

  # PUT /competitions/1/age_groups/separate?age_group_combination_id=1
  def separate
    combination = @competition.age_group_combinations.find(params[:age_group_combination_id])
    separated_entries = combination.sorted_age_group_entries.map(&:to_s).to_sentence

    combiner = AgeGroupCombiner.new(@competition)
    if combiner.separate(combination)
      flash[:notice] = "Separated #{separated_entries}"
    else
      flash[:alert] = combiner.error_message
    end
    redirect_to competition_age_groups_path(@competition)
  end

  # PUT /competitions/1/age_groups/rename?age_group_combination_id=1&name=Juniors
  def rename
    combination = @competition.age_group_combinations.find(params[:age_group_combination_id])

    combiner = AgeGroupCombiner.new(@competition)
    if combiner.rename(combination, params[:name])
      flash[:notice] = "Renamed to #{combination}"
    else
      flash[:alert] = combiner.error_message
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
