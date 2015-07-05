class HeatsController < ApplicationController
  before_action :authenticate_user!
  load_and_authorize_resource :competition, except: [:edit, :update, :destroy]

  before_action :set_parent_breadcrumbs
  before_action :load_age_group_entry, only: [:sort, :set_sort]

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

  # process a form submission which includes HEAT&Lane for each candidate, creating the nocessary lane assignment
  # It creates heats for each age group
  # parameters:
  #  - Lanes - maximum number of lanes for each heat
  def create
    max_lane_number = params[:lanes].to_i
    begin
      raise "invalid settings" if max_lane_number == 0
      raise "Existing Lane Assignments" if @competition.lane_assignments.any?
      current_heat = 1
      LaneAssignment.transaction do
        @competition.age_group_entries.each do |ag_entry|
          age_group_entries = @competition.competitors.includes(members: [registrant: :registrant_choices]).select {|competitor| competitor.age_group_entry == ag_entry }
          current_heat = create_heats_from(age_group_entries, current_heat, max_lane_number)
        end
      end
      flash[:notice] = "Created Heats/Lanes from Competitors"
    rescue Exception => ex
      flash[:alert] = "Error creating lane assignments/competitors #{ex}"
    end
    redirect_to competition_heats_path(@competition)
  end

  def sort
    @lane_assignments = LaneAssignment.where(id: params[:age_group_entry]).order(:heat, :lane)

    # holds the list of all heats/lanes
    previous_heat_lanes = @lane_assignments.map{|la| [la.heat, la.lane] }

    # enable a mode which assigns new lane numbers (but not heats)
    if params[:move_lane]
      move_to_new_position = true
      found_moved_lane = false
    end

    # XXX this is doing unsafe updates (validations disabled)
    # sets these to the new order given
    new_lanes = []
    moved_heat = 0
    moved_lane = 0
    params[:age_group_entry].each_with_index do |lane_assignment_id, index|
      la = LaneAssignment.find(lane_assignment_id)
      if previous_heat_lanes[index][0] != la.heat || previous_heat_lanes[index][1] != la.lane
        # this lane has been moved
        if move_to_new_position
          unless found_moved_lane
            moved_heat = previous_heat_lanes[index][0]
            moved_lane = previous_heat_lanes[index][1]
            found_moved_lane = true
          end
          if found_moved_lane && la.heat == moved_heat && la.lane == moved_lane
            # this is the lane that we moved
            la.update_attribute(:heat, previous_heat_lanes[index][0])
            la.update_attribute(:lane, previous_heat_lanes[index][1] + 1)
          end
        else
          la.update_attribute(:heat, previous_heat_lanes[index][0])
          la.update_attribute(:lane, previous_heat_lanes[index][1])
        end
      end
      new_lanes << la
    end
    @lane_assignments = new_lanes
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

  def create_heats_from(competitors, current_heat, max_lane_number)
    next_lane_number = 1
    heat_number = current_heat
    competitors.sort{|a, b| b.best_time <=> a.best_time}.each do |competitor|
      if next_lane_number > max_lane_number
        heat_number += 1
        next_lane_number = 1
      end
      LaneAssignment.create!(competitor: competitor, lane: next_lane_number, heat: heat_number, competition: competitor.competition)
      next_lane_number += 1
    end
    return heat_number if next_lane_number == 1
    heat_number + 1
  end

  def load_age_group_entry
    @age_group_entry = AgeGroupEntry.find(params[:age_group_entry_id])
  end

  def set_parent_breadcrumbs
    add_breadcrumb "#{@competition}", competition_path(@competition)
  end
end
