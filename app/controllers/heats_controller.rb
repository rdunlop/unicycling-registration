require 'csv'
class HeatsController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource :competition, except: [:edit, :update, :destroy]

  before_action :set_parent_breadcrumbs
  before_action :load_age_group_entry, only: [:sort, :set_sort]

  respond_to :html

  # GET /competitions/:competition_id/1/competitors/new
  def new
    add_breadcrumb "Create Track Lane Assignments"
  end

  # GET /competitions/1/competitors
  def index
    add_breadcrumb "Current Heats"
    @competitors = @competition.competitors
  end

  def create_heats_from(competitors, current_heat, max_lane_number)
    lane_number = 1
    heat_number = current_heat
    competitors.each do |competitor|
      if lane_number > max_lane_number
        heat_number += 1
        lane_number = 1
      end
      LaneAssignment.create!(competitor: competitor, lane: lane_number, heat: heat_number, competition: competitor.competition)
      lane_number += 1
    end
    return heat_number if lane_number == 1
    heat_number + 1
  end

  # process a form submission which includes HEAT&Lane for each candidate, creating the competitor as well as the lane assignment
  def create
    max_lane_number = params[:lanes].to_i
    begin
      raise "invalid settings" if max_lane_number == 0
      raise "Existing Lane Assignments" if @competition.lane_assignments.any?
      current_heat = 1
      LaneAssignment.transaction do
        @competition.age_group_entries.each do |ag_entry|
          age_group_entries = @competition.competitors.select {|competitor| competitor.age_group_entry == ag_entry }
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

    # XXX this is doing unsafe updates (validations disabled)
    # sets these to the new order given
    new_lanes = []
    params[:age_group_entry].each_with_index do |lane_assignment_id, index|
      la = LaneAssignment.find(lane_assignment_id)
      la.update_attribute(:heat, previous_heat_lanes[index][0])
      la.update_attribute(:lane, previous_heat_lanes[index][1])
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

  def upload_form
  end

  def upload
    if params[:file].respond_to?(:tempfile)
      file = params[:file].tempfile
    else
      file = params[:file]
    end

    begin
      Competitor.transaction do
        File.open(file, 'r:ISO-8859-1') do |f|
          f.each do |line|
            row = CSV.parse_line (line)
            bib_number = row[0]
            heat = row[1]
            competitor = @competition.competitors.where(lowest_member_bib_number: bib_number).first
            raise "Unable to find competitor #{bib_number}" if competitor.nil?
            competitor.update_attribute(:heat, heat)
          end
        end
      end
      flash[:notice] = "Heats Configured"
    rescue Exception => ex
      flash[:alert] = "Error processing file #{ex}"
    end

    redirect_to competition_heats_path(@competition)
  end

  # DELETE /events/10/competitors/destroy_all
  def destroy_all
    @competition.lane_assignments.destroy_all

    respond_with(@competition, location: competition_heats_path(@competition))
  end

  private
  def load_age_group_entry
    @age_group_entry = AgeGroupEntry.find(params[:age_group_entry_id])
  end

  def set_parent_breadcrumbs
    add_breadcrumb "#{@competition}", competition_path(@competition)
  end
end
