class Compete::TierAssignmentsController < ApplicationController
  include CsvOutputter
  include WaveBestTimeEagerLoader
  layout "competition_management"

  before_action :authenticate_user!
  before_action :load_competition
  before_action :set_parent_breadcrumbs

  respond_to :html

  # GET /competitions/1/tier_assignments
  def show
    authorize @competition, :assign_tiers?
    add_breadcrumb "Current Tiers"
    @competitors = eager_load_competitors_relations(@competition.competitors)
    respond_to do |format|
      format.csv do
        exporter = Exporters::TierExporter.new(@competitors)
        headers = exporter.headers
        data = exporter.rows
        output_csv(headers, data, "#{@competition.slug}-tiers-draft-#{Date.current}.csv")
      end
      format.html {}
    end
  end

  # PUT /competitions/1/tier_assignments
  def update
    authorize @competition, :assign_tiers?

    uploaded_file = UploadedFile.process_params(params, competition: @competition, user: current_user)
    parser = Importers::Parsers::Tier.new(uploaded_file.original_file.file)
    updater = Importers::TierUpdater.new(@competition, current_user)

    if updater.process(parser)
      flash[:notice] = "#{updater.num_rows_processed} Tiers Configured"
      redirect_to competition_tier_assignments_path(@competition)
    else
      flash[:alert] = "Error processing file #{updater.errors}"
      redirect_back(fallback_location: competition_tier_assignments_path(@competition))
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
