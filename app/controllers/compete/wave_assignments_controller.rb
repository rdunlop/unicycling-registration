require 'csv'
class Compete::WaveAssignmentsController < ApplicationController
  layout "competition_management"
  before_action :authenticate_user!
  before_action :load_competition
  before_action :set_parent_breadcrumbs

  respond_to :html

  # GET /competitions/1/waves
  def show
    authorize @competition, :show?
    add_breadcrumb "Current Waves"
    @competitors = @competition.competitors
    respond_to do |format|
      format.xls do
        s = Spreadsheet::Workbook.new

        sheet = s.create_worksheet
        sheet[0, 0] = "ID"
        sheet[0, 1] = "Wave"
        sheet[0, 2] = "Name"
        @competitors.each.with_index(1) do |comp, row_number|
          sheet[row_number, 0] = comp.lowest_member_bib_number
          sheet[row_number, 1] = comp.wave
          sheet[row_number, 2] = comp.detailed_name
        end

        report = StringIO.new
        s.write report
        send_data report.string, filename: "#{@competition.slug}-waves-draft-#{Date.today}.xls"
      end
      format.html {} # normal
    end
  end

  # PUT /competitions/1/waves
  def update
    authorize @competition, :modify_result_data?
    if params[:file].respond_to?(:tempfile)
      file = params[:file].tempfile
    else
      file = params[:file]
    end

    begin
      Competitor.transaction do
        File.open(file, 'r:ISO-8859-1') do |f|
          f.each_with_index do |line, index|
            next if index == 0
            row = CSV.parse_line (line)
            bib_number = row[0]
            wave = row[1]
            # skip blank lines
            next if bib_number.nil? && wave.nil?
            competitor = @competition.competitors.where(lowest_member_bib_number: bib_number).first
            raise "Unable to find competitor #{bib_number}" if competitor.nil?
            competitor.update_attribute(:wave, wave)
          end
        end
      end
      flash[:notice] = "Waves Configured"
    rescue Exception => ex
      flash[:alert] = "Error processing file #{ex}"
    end

    redirect_to competition_waves_path(@competition)
  end

  private

  def load_competition
    @competition = Competition.find(params[:competition_id])
  end

  def set_parent_breadcrumbs
    add_breadcrumb "#{@competition}", competition_path(@competition)
  end
end
