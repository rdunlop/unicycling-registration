class LaneAssignmentsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :load_competition, :only => [:index, :create, :view_heat, :dq_competitor]
  before_filter :load_new_lane_assignment, :only => [:create]
  load_and_authorize_resource

  before_action :set_parent_breadcrumbs, only: [:index, :create]

  def view_heat
    @heat = params[:heat]
    @lane_assignments = @competition.lane_assignments.where(heat: @heat)
    @dq_request = DQRequest.new(heat: @heat)
  end

  def dq_competitor
    @dq_request = DQRequest.new(params[:dq_request])

    bib_number = @dq_request.bib_number
    @heat = @dq_request.heat

    @ir = ImportResult.new(
      bib_number: bib_number,
      status: "DQ",
      comments: @dq_request.comments,
      competition: @competition,
      user: current_user
      )

    respond_to do |format|
      if @ir.save
        format.html { redirect_to view_heat_competition_lane_assignments_path(@competition, heat: @heat), notice: 'Competitor successfully dq.' }
      else
        add_breadcrumb "View Heat"
        @lane_assignments = @competition.lane_assignments.where(heat: heat)
        format.html { render action: "view_heat" }
      end
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
    add_breadcrumb "Edit Lane Assignment"
  end

  # POST /lane_assignments
  # POST /lane_assignments.json
  def create
    respond_to do |format|
      if @lane_assignment.save
        format.html { redirect_to competition_lane_assignments_path(@competition), notice: 'Lane assignment was successfully created.' }
      else
        add_breadcrumb "Lane Assignments"
        @lane_assignments = @competition.lane_assignments
        format.html { render action: "index" }
      end
    end
  end

  # PUT /lane_assignments/1
  # PUT /lane_assignments/1.json
  def update

    respond_to do |format|
      if @lane_assignment.update_attributes(lane_assignment_params)
        format.html { redirect_to competition_lane_assignments_path(@lane_assignment.competition), notice: 'Lane assignment was successfully updated.' }
      else
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

  def lane_assignment_params
    params.require(:lane_assignment).permit(:registrant_id, :heat, :lane)
  end

  def set_parent_breadcrumbs
    add_to_competition_breadcrumb(@competition)
  end

  def load_competition
    @competition = Competition.find(params[:competition_id])
    raise StandardError.new("Competition is not set to use lane assignments") unless @competition.uses_lane_assignments
  end

  def load_new_lane_assignment
    @lane_assignment = @competition.lane_assignments.new(lane_assignment_params)
  end


end
