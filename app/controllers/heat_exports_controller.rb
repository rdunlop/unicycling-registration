class HeatExportsController < ApplicationController
  before_action :authenticate_user!
  before_action :load_competition
  before_action :set_parent_breadcrumbs
  before_action :authorize_competition

  # GET /competitions/1/heat_exports
  def index
    add_breadcrumb "Current Heats"
    @competitors = @competition.competitors
  end

  # GET /competitions/1/heat_exports/download_evt
  def download_evt
    csv_string = CSV.generate do |csv|
      @competition.heat_numbers.each do |heat_number|
        create_heat_evt(csv, heat_number)
      end
    end

    filename = "heats_#{@competition.to_s.parameterize}.evt"
    send_data(csv_string,
              type: 'text/csv; charset=utf-8; header=present',
              filename: filename)
  end

  private

  def create_heat_evt(csv, heat)
    lane_assignments = LaneAssignment.where(heat: heat, competition: @competition)
    csv << [@competition.id, 1, heat, @competition]
    lane_assignments.each do |lane_assignment|
      member = lane_assignment.competitor.members.first.registrant
      csv << [nil,
              lane_assignment.competitor.lowest_member_bib_number,
              lane_assignment.lane,
              ActiveSupport::Inflector.transliterate(member.last_name),
              ActiveSupport::Inflector.transliterate(member.first_name),
              ActiveSupport::Inflector.transliterate(member.country)]
    end
  end

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
