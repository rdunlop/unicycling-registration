class CandidatesController < ApplicationController
  layout "competition_management"

  before_action :authenticate_user!
  before_action :load_competition

  before_action :set_parent_breadcrumbs

  # show the competitors, their overall places, and their times
  def index
    authorize @competition.competitors.new
    add_breadcrumb "Display Competition Candidates"
    @competitors = @competition.signed_up_competitors

    if params[:sort]
      case params[:sort]
      when "result"
        @competitors = @competitors.sort_by{|a| a.result }
      when "gender"
        @competitors = @competitors.sort_by{|a| [a.gender, a.overall_place] }
      end
    end

    if params[:gender]
      @gender = params[:gender]
      @lanes_for_places = []
      (1..8).each do |i|
        @lanes_for_places[i] = params["lane_for_place_#{i}"]
      end
    end

    respond_to do |format|
      format.html
      format.pdf { render_common_pdf "index" }
    end
  end

  # process a form submission which includes HEAT&Lane for each candidate, creating the competitor as well as the lane assignment
  def create_from_candidates
    authorize @competition.competitors.new

    heat = params[:heat].to_i
    competitors = params[:competitors]
    begin
      LaneAssignment.transaction do
        competitors.each do |_, competitor|
          reg = Registrant.find_by!(bib_number: competitor[:bib_number])
          lane_assignment = LaneAssignment.new(registrant_id: reg.id, lane: competitor[:lane].to_i, heat: heat, competition: @competition)
          lane_assignment.save!
        end
      end
      flash[:notice] = "Created Lane Assignments & Competitors"
    rescue Exception => ex
      flash[:alert] = "Error creating lane assignments/competitors #{ex}"
    end
    redirect_to competition_competitors_path(@competition)
  end

  private

  def load_competition
    @competition = Competition.find(params[:competition_id])
  end

  def set_parent_breadcrumbs
    @competition ||= @competitor.competition
    add_competition_setup_breadcrumb
    add_breadcrumb @competition.to_s, competition_path(@competition)
    add_breadcrumb "Manage Competitors", competition_competitors_path(@competition) if @competitor
  end
end
