class LaneAssignmentsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :load_competition, except: [:edit, :update, :destroy]
  before_filter :load_new_lane_assignment, :only => [:create]
  load_and_authorize_resource through: :competition, except: [:edit, :update, :destroy]
  load_and_authorize_resource only: [:edit, :update, :destroy]

  before_action :set_parent_breadcrumbs, only: [:index, :create]

  def review
    @heat_numbers = @lane_assignments.map(&:heat).uniq.sort
  end

  def create_heat_evt(csv, heat)
    lane_assignments = LaneAssignment.where(heat: heat, competition: @competition)
    csv << [@competition.id, 1, heat, @competition]
    lane_assignments.each do |lane_assignment|
      member = lane_assignment.competitor.members.first.registrant
      csv << [nil,
        lane_assignment.competitor.lowest_member_bib_number,
        lane_assignment.lane,
        member.last_name,
        member.first_name,
        member.country]
    end
  end

  def download_heats_evt
    csv_string = CSV.generate do |csv|
      @competition.heat_numbers.each do |heat_number|
        create_heat_evt(csv, heat_number)
      end
    end

    filename = "heats_#{@competition.to_s.parameterize}.evt"
    send_data(csv_string,
              :type => 'text/csv; charset=utf-8; header=present',
              :filename => filename)
  end

  def view_heat
    @heat = params[:heat].to_i if params[:heat]
    @heat ||= @competition.lane_assignments.minimum(:heat) || 0
    @lane_assignments = @competition.lane_assignments.where(heat: @heat)
    if @lane_assignments.empty?
      @other_competition = LaneAssignment.where(heat: @heat).first.try(:competition)
    end
  end

  def dq_competitor
    @dq_request = DQRequest.new(params[:dq_request])

    bib_number = @dq_request.bib_number
    @heat = @dq_request.heat.to_i
    @lane = @dq_request.lane.to_i

    ir = ImportResult.new(
      heat: @heat,
      lane: @lane,
      bib_number: bib_number,
      status: "DQ",
      comments: @dq_request.comments,
      comments_by: @dq_request.comments_by,
      competition: @competition,
      user: current_user
      )

    respond_to do |format|
      if ir.save
        format.html { redirect_to :back, notice: 'Competitor successfully dq.' }
      else
        add_breadcrumb "View Heat"
        @lane_assignments = @competition.lane_assignments.where(heat: @heat)
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
    @competition = @lane_assignment.competition
    add_breadcrumb "Edit Lane Assignment"
  end

  # POST /lane_assignments
  # POST /lane_assignments.json
  def create
    respond_to do |format|
      if @lane_assignment.save
        format.html { redirect_to competition_lane_assignments_path(@competition), notice: 'Lane assignment was successfully created.' }
        format.js { }
      else
        add_breadcrumb "Lane Assignments"
        @lane_assignments = @competition.lane_assignments
        format.html { render action: "index" }
        format.js { }
      end
    end
  end

  # PUT /lane_assignments/1
  # PUT /lane_assignments/1.json
  def update

    respond_to do |format|
      if @lane_assignment.update_attributes(lane_assignment_params)
        format.html { redirect_to competition_lane_assignments_path(@lane_assignment.competition), notice: 'Lane assignment was successfully updated.' }
        format.js { render :js => "window.location.replace('#{competition_lane_assignments_path(@lane_assignment.competition)}');" }
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

  def lane_assignment_params
    params.require(:lane_assignment).permit(:competitor_id, :heat, :lane, :registrant_id)
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
