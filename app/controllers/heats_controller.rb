class HeatsController < ApplicationController
  before_action :authenticate_user!
  before_action :load_competition
  before_action :set_parent_breadcrumbs
  before_action :load_age_group_entry, only: [:sort, :set_sort]
  before_action :authorize_competition

  respond_to :html

  # GET /competitions/1/heats
  def index
    add_breadcrumb "Current Heats"
    @competitors = @competition.competitors
  end

  # GET /competitions/1/heats/new
  def new
    add_breadcrumb "Create Track Lane Assignments"
  end

  # process a form submission which includes HEAT&Lane for each candidate, creating the necessary lane assignment
  # It creates heats for each age group
  # parameters:
  #  - lanes - maximum number of lanes for each heat
  #  - lane_order - the priority order of lane assignments, as a space-separated string of numbers
  def create
    max_lane_number = params[:lanes].to_i
    lane_assignment_order = params[:lane_order].split(" ")
    if max_lane_number <= 0
      flash[:alert] = "Error: Invalid number of lanes"
    elsif @competition.lane_assignments.any?
      flash[:alert] = "Error: Cannot auto-assign with existing Lane Assignments"
    else
      calculator = HeatLaneCalculator.new(max_lane_number, lane_assignment_order: lane_assignment_order)
      if calculator.valid?
        creator = HeatAssignmentCreator.new(@competition, calculator)
        if creator.perform
          flash[:notice] = "Created Heats/Lanes from Competitors"
        else
          flash[:alert] = "error: #{creator.error}"
        end
      else
        flash[:alert] = "error: #{calculator.error}"
      end
    end

    redirect_to competition_heats_path(@competition)
  end

  # manually re-sort the lane assignments
  def sort
    sorter = HeatLaneSorter.new(params[:age_group_entry], move_lane: params[:move_lane])
    @lane_assignments = sorter.sort
    respond_to do |format|
      format.js {}
    end
  end

  # GET /competitions/#/heats/:age_group_entry_id:/set_sort
  def set_sort
    add_breadcrumb "Set Heat/Lane assignment order"
    @lane_assignments = @competition.lane_assignments.includes(:competitor).select { |lane_assignment| lane_assignment.competitor.age_group_entry == @age_group_entry }
  end

  # DELETE /events/10/competitors/destroy_all
  def destroy_all
    @competition.lane_assignments.destroy_all

    respond_with(@competition, location: competition_heats_path(@competition))
  end

  private

  def authorize_competition
    authorize @competition, :heat_recording?
  end

  def load_age_group_entry
    @age_group_entry = AgeGroupEntry.find(params[:age_group_entry_id])
  end

  def set_parent_breadcrumbs
    add_breadcrumb @competition.to_s, competition_path(@competition)
  end

  def load_competition
    @competition = Competition.find(params[:competition_id])
  end
end
