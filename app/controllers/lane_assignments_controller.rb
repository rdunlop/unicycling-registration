class LaneAssignmentsController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource

  # GET /lane_assignments
  # GET /lane_assignments.json
  def index
    @lane_assignments = LaneAssignment.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @lane_assignments }
    end
  end

  # GET /lane_assignments/1
  # GET /lane_assignments/1.json
  def show
    @lane_assignment = LaneAssignment.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @lane_assignment }
    end
  end

  # GET /lane_assignments/new
  # GET /lane_assignments/new.json
  def new
    @lane_assignment = LaneAssignment.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @lane_assignment }
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

    respond_to do |format|
      if @lane_assignment.save
        format.html { redirect_to @lane_assignment, notice: 'Lane assignment was successfully created.' }
        format.json { render json: @lane_assignment, status: :created, location: @lane_assignment }
      else
        format.html { render action: "new" }
        format.json { render json: @lane_assignment.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /lane_assignments/1
  # PUT /lane_assignments/1.json
  def update
    @lane_assignment = LaneAssignment.find(params[:id])

    respond_to do |format|
      if @lane_assignment.update_attributes(params[:lane_assignment])
        format.html { redirect_to @lane_assignment, notice: 'Lane assignment was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @lane_assignment.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /lane_assignments/1
  # DELETE /lane_assignments/1.json
  def destroy
    @lane_assignment = LaneAssignment.find(params[:id])
    @lane_assignment.destroy

    respond_to do |format|
      format.html { redirect_to lane_assignments_url }
      format.json { head :no_content }
    end
  end
end
