# == Schema Information
#
# Table name: lane_assignments
#
#  id             :integer          not null, primary key
#  competition_id :integer
#  heat           :integer
#  lane           :integer
#  created_at     :datetime
#  updated_at     :datetime
#  competitor_id  :integer
#
# Indexes
#
#  index_lane_assignments_on_competition_id                    (competition_id)
#  index_lane_assignments_on_competition_id_and_heat_and_lane  (competition_id,heat,lane) UNIQUE
#

class LaneAssignmentsController < ApplicationController
  before_action :authenticate_user!
  before_action :load_and_authorize_competition, except: %i[edit update destroy]
  before_action :load_lane_assignments, except: %i[edit update destroy index create]
  before_action :load_lane_assignment, only: %i[edit update destroy]
  before_action :authorize_competition, only: %i[edit update destroy]

  before_action :set_parent_breadcrumbs, only: %i[index create]

  def review
    @heat_numbers = @lane_assignments.map(&:heat).uniq.sort
  end

  def view_heat
    @heat = params[:heat].to_i if params[:heat]
    @heat ||= @competition.lane_assignments.minimum(:heat) || 0
    @lane_assignments = @competition.lane_assignments.where(heat: @heat)
    @heat_lane_judge_note = HeatLaneJudgeNote.new(heat: @heat)
    if @lane_assignments.empty?
      @other_competition = LaneAssignment.where(heat: @heat).first.try(:competition)
    end
  end

  def dq_competitor
    @heat_lane_judge_note = HeatLaneJudgeNote.new(heat_lane_judge_note_params)

    @heat_lane_judge_note.competition = @competition
    @heat_lane_judge_note.entered_by = current_user
    @heat_lane_judge_note.entered_at = Time.current
    @heat_lane_judge_note.status = "DQ"

    if @heat_lane_judge_note.save
      flash[:notice] = 'Competitor successfully dq.'
      redirect_back(fallback_location: view_heat_competition_lane_assignments_path(@competition))
    else
      flash.now[:alert] = "Error marking Heat #{@heat_lane_judge_note.heat} lane #{@heat_lane_judge_note.lane} as DQ"
      add_breadcrumb "View Heat"
      @heat = @heat_lane_judge_note.heat
      @lane_assignments = @competition.lane_assignments.where(heat: @heat)
      render action: "view_heat"
    end
  end

  # GET /competitions/#/lane_assignments
  # GET /competitions/#/lane_assignments.json
  def index
    add_breadcrumb "Lane Assignments"

    @lane_assignment = LaneAssignment.new
    @lane_assignments = @competition.lane_assignments

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @lane_assignments }
    end
  end

  # GET /lane_assignments/1/edit
  def edit
    @competition = @lane_assignment.competition
    add_breadcrumb "Edit Lane Assignment"
  end

  # POST /lane_assignments
  # POST /lane_assignments.json
  def create
    @lane_assignment = @competition.lane_assignments.build(lane_assignment_params)

    respond_to do |format|
      if @lane_assignment.save
        format.html { redirect_to competition_lane_assignments_path(@competition), notice: 'Lane assignment was successfully created.' }
        format.js {}
      else
        add_breadcrumb "Lane Assignments"
        @lane_assignments = @competition.lane_assignments
        format.html { render action: "index" }
        format.js {}
      end
    end
  end

  # PUT /lane_assignments/1
  # PUT /lane_assignments/1.json
  def update
    respond_to do |format|
      if @lane_assignment.update(lane_assignment_params)
        format.html { redirect_to competition_lane_assignments_path(@lane_assignment.competition), notice: 'Lane assignment was successfully updated.' }
        format.js { render js: "window.location.replace('#{competition_lane_assignments_path(@lane_assignment.competition)}');" }
      else
        @competition = @lane_assignment.competition
        format.html { render action: "edit" }
      end
    end
  end

  # DELETE /lane_assignments/1
  # DELETE /lane_assignments/1.json
  def destroy
    @competition = @lane_assignment.competition
    @lane_assignment.destroy

    respond_to do |format|
      format.html { redirect_to competition_lane_assignments_path(@competition) }
      format.json { head :no_content }
    end
  end

  private

  def heat_lane_judge_note_params
    params.require(:heat_lane_judge_note).permit(:heat, :lane, :status, :comments)
  end

  def authorize_competition
    authorize @lane_assignment.competition, :manage_lane_assignments?
  end

  def lane_assignment_params
    params.require(:lane_assignment).permit(:competitor_id, :heat, :lane, :registrant_id)
  end

  def set_parent_breadcrumbs
    add_to_competition_breadcrumb(@competition)
  end

  def load_and_authorize_competition
    @competition = Competition.find(params[:competition_id])
    authorize @competition, :manage_lane_assignments?
    unless @competition.uses_lane_assignments?
      flash[:alert] = "Competition is not set to use lane assignments"
      redirect_back(fallback_location: root_path)
    end
  end

  def load_lane_assignments
    @lane_assignments = @competition.lane_assignments
  end

  def load_lane_assignment
    @lane_assignment = LaneAssignment.find(params[:id])
  end
end
