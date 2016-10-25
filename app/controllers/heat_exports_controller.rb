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

  # GET /competitions/1/heat_exports/download_competitor_list_csv
  #
  # StartNr;Nachname;Vorname;Land;Geschlecht;AK
  # 2;Durgan;Whitney;USA;f;30+
  # 3;Crist;Amely;USA;f;30+
  def download_competitor_list_ssv
    csv_string = CSV.generate(col_sep: ";") do |csv|
      csv << ["ID", "LastName", "FirstName", "Country", "Gender", "Age Group"]
      @competition.competitors.each do |competitor|
        csv << [
          competitor.bib_number,
          nil,
          ActiveSupport::Inflector.transliterate(competitor.name),
          competitor.country,
          competitor.gender,
          competitor.age_group_entry_description
        ]
      end
    end

    filename = "competitors_#{@competition.to_s.parameterize}.txt"
    send_data(csv_string,
              type: 'text/csv; charset=utf-8; header=present',
              filename: filename)
  end

  # GET /competitions/1/heat_exports/
  #
  # Parameters:
  #
  # heat_number
  #
  # Return a tab-separated list of each heat
  # Example:
  #
  # nil nil 698 1 Durgan Whitney  Germany 30+ w
  # nil nil 92  2 Crist Amely Italy 30+ w
  # nil nil 543 3 Spinka Hank  Germany 30+ w
  # nil nil 364 4 Larkin Cara Kornelia  Switzerland 30+ w
  # nil nil 81  5 Hills Raegan  Italy 30+ w
  # nil nil 498 6 Walter Yvette  Germany 30+ w
  #
  # returns a single file for the heat
  def download_heat_tsv
    heat = params[:heat_number]
    csv_string = HeatTsvGenerator.new(@competition, heat).generate

    filename = "#{@competition.to_s.parameterize}_heat_#{heat}.txt"
    send_data(csv_string,
              type: 'text/csv; charset=utf-8; header=present',
              filename: filename)
  end

  # POST /competitions/1/heat_expors/download_all_heats_tsv
  #
  # returns a zip file containing all of the heat files together
  def download_all_heats_tsv
    zip_creator = CompetitionHeatTsvZipCreator.new(@competition)
    filename = @competition.to_s.gsub(/[^0-9a-zA-Z]/, '') + '_heats.zip'
    zip_creator.zip_file(filename) do |zip_file|
      send_data(zip_file, type: 'application/zip', filename: filename)
    end
  end

  private

  def create_heat_evt(csv, heat)
    lane_assignments = LaneAssignment.where(heat: heat, competition: @competition)
    csv << [@competition.id, 1, heat, @competition]
    lane_assignments.each do |lane_assignment|
      member = lane_assignment.competitor.members.first.registrant
      country = if member.country.nil?
                  nil
                else
                  ActiveSupport::Inflector.transliterate(member.country)
                end
      csv << [nil,
              lane_assignment.competitor.lowest_member_bib_number,
              lane_assignment.lane,
              ActiveSupport::Inflector.transliterate(member.last_name),
              ActiveSupport::Inflector.transliterate(member.first_name),
              country]
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
