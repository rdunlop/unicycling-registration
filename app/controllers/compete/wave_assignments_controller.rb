class Compete::WaveAssignmentsController < ApplicationController
  include CsvOutputter
  include WaveBestTimeEagerLoader
  layout "competition_management"
  before_action :authenticate_user!
  before_action :load_competition
  before_action :set_parent_breadcrumbs

  respond_to :html

  # GET /competitions/1/waves
  def show
    authorize @competition, :show?
    add_breadcrumb "Current Waves"
    @competitors = eager_load_competitors_relations(@competition.competitors)

    respond_to do |format|
      format.csv do
        exporter = Exporters::WaveExporter.new(@competitors)
        headers = exporter.headers
        data = exporter.rows
        output_csv(headers, data, "#{@competition.slug}-waves-draft-#{Date.current}.csv")
      end
      format.html {} # normal
    end
  end

  # PUT /competitions/1/waves
  def update
    authorize @competition, :modify_result_data?

    uploaded_file = UploadedFile.process_params(params, competition: @competition, user: current_user)
    parser = Importers::Parsers::Wave.new(uploaded_file.original_file.file)
    updater = Importers::WaveUpdater.new(@competition, current_user)

    if updater.process(parser)
      flash[:notice] = "#{updater.num_rows_processed} Waves Configured"
      redirect_to competition_waves_path(@competition)
    else
      flash[:alert] = "Error processing file #{updater.errors}"
      redirect_back(fallback_location: competition_waves_path(@competition))
    end
  end

  private

  def load_competition
    @competition = Competition.find(params[:competition_id])
  end

  def set_parent_breadcrumbs
    add_breadcrumb @competition.to_s, competition_path(@competition)
  end
end
