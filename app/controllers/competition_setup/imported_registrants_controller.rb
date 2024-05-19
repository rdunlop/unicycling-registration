class CompetitionSetup::ImportedRegistrantsController < CompetitionSetup::BaseCompetitionSetupController
  include CsvOutputter
  before_action :authenticate_user!
  before_action :authorize_imported_registrant_management
  before_action :load_imported_registrants, only: %i[index create]

  def index
    @new_imported_registrant = ImportedRegistrant.new
    respond_to do |format|
      format.csv do
        exporter = Exporters::ImportedRegistrantsExporter.new(ImportedRegistrant.all)
        headers = exporter.headers
        data = exporter.rows
        output_csv(headers, data, "imported-registrants-#{Date.current}.csv")
      end
      format.html {}
    end
  end

  def create
    @new_imported_registrant = ImportedRegistrant.new(imported_registrant_params)
    if @new_imported_registrant.save
      flash[:notice] = "Imported Registrant successfully created"
      redirect_to imported_registrants_path
    else
      render :index
    end
  end

  # POST /imported_registrants/upload
  def upload
    uploaded_file = UploadedFile.process_params(params, user: current_user)

    parser = Importers::Parsers::ImportedRegistrant.new(uploaded_file.original_file.file)
    updater = Importers::ImportedRegistrantsUpdater.new(current_user)

    if updater.process(parser)
      flash[:notice] = "#{updater.num_rows_processed} Registrants Imported"
      redirect_to imported_registrants_path
    else
      flash[:alert] = "Error processing file #{updater.errors}"
      redirect_back(fallback_location: imported_registrants_path)
    end
  end

  def destroy
    @imported_registrant = ImportedRegistrant.find(params[:id])

    if @imported_registrant.destroy
      flash[:notice] = "Imported Regisrtant deleted"
      # should this be soft-delete?
    else
      flash[:alert] = "Unable to delete Imported Registrant (is it in use?)"
    end
    redirect_to imported_registrants_path
  end

  private

  def load_imported_registrants
    @imported_registrants = ImportedRegistrant.all
  end

  def authorize_imported_registrant_management
    authorize @config, :setup_competition?
  end

  def imported_registrant_params
    params.require(:imported_registrant).permit(:bib_number,
                                                :first_name, :last_name, :age, :birthday, :club)
  end
end
