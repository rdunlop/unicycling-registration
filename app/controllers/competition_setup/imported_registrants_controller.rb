class CompetitionSetup::ImportedRegistrantsController < CompetitionSetup::BaseCompetitionSetupController
  before_action :authenticate_user!
  before_action :authorize_imported_registrant_management
  before_action :load_imported_registrants, only: [:index, :create]

  def index
    @new_imported_registrant = ImportedRegistrant.new
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
      :first_name, :last_name)
  end
end
