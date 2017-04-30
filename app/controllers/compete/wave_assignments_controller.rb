class Compete::WaveAssignmentsController < ApplicationController
  include ExcelOutputter
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
        exporter = Exporters::WaveExporter.new(@competitors)
        headers = exporter.headers
        data = exporter.rows
        output_spreadsheet(headers, data, "#{@competition.slug}-waves-draft-#{Date.today}")
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

    parser = Importers::Parsers::Wave.new
    updater = Importers::WaveUpdater.new(@competition, current_user)

    if updater.process(file, parser)
      flash[:notice] = "{importer.num_rows_processed} Waves Configured"
    else
      flash[:alert] = "Error processing file #{updater.errors}"
    end

    redirect_to competition_waves_path(@competition)
  end

  private

  def load_competition
    @competition = Competition.find(params[:competition_id])
  end

  def set_parent_breadcrumbs
    add_breadcrumb @competition.to_s, competition_path(@competition)
  end
end
