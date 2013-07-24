class LaneAssignmentsController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource

  before_filter :load_competition, :only => [:index, :create]

  def load_competition
    @competition = Competition.find(params[:competition_id])
  end

  # GET /competitions/#/lane_assignments
  # GET /competitions/#/lane_assignments.json
  def index
    @lane_assignment = LaneAssignment.new
    @lane_assignments = @competition.lane_assignments

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @lane_assignments }
    end
  end

  # GET /lane_assignments/1/edit
  def edit
    @lane_assignment = LaneAssignment.find(params[:id])
  end

  # POST /lane_assignments
  # POST /lane_assignments.json
  def create
    @lane_assignment = LaneAssignment.new(params[:lane_assignment])
    @lane_assignment.competition = @competition

    respond_to do |format|
      if @lane_assignment.save
        format.html { redirect_to competition_lane_assignments_path(@competition), notice: 'Lane assignment was successfully created.' }
      else
        @lane_assignments = @competition.lane_assignments
        format.html { render action: "index" }
      end
    end
  end

  # PUT /lane_assignments/1
  # PUT /lane_assignments/1.json
  def update
    @lane_assignment = LaneAssignment.find(params[:id])

    respond_to do |format|
      if @lane_assignment.update_attributes(params[:lane_assignment])
        format.html { redirect_to competition_lane_assignments_path(@lane_assignment.competition), notice: 'Lane assignment was successfully updated.' }
      else
        format.html { render action: "edit" }
      end
    end
  end

  # DELETE /lane_assignments/1
  # DELETE /lane_assignments/1.json
  def destroy
    @lane_assignment = LaneAssignment.find(params[:id])
    @competition = @lane_assignment.competition
    @lane_assignment.destroy

    respond_to do |format|
      format.html { redirect_to competition_lane_assignments_path(@competition) }
      format.json { head :no_content }
    end
  end
end
