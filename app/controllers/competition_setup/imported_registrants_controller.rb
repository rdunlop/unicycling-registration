class CompetitionSetup::ImportedRegistrantsController < CompetitionSetup::BaseCompetitionSetupController
  before_action :authenticate_user!
  before_action :authorize_imported_registrant_management

  def index
    @imported_registrants = ImportedRegistrant.all
    @new_imported_registrant = ImportedRegistrant.new
  end

  def create
    @imported_registrant = nil #@params.permit...

  private

  def authorize_imported_registrant_management
    authorize @config, :setup_competition?
  end
end
