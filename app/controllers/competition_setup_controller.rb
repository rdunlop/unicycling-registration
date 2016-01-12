class CompetitionSetupController < CompetitionSetup::BaseCompetitionSetupController
  before_action :authenticate_user!
  before_action :set_breadcrumb

  def index
    authorize @config, :setup_competition?

    @categories = Category.includes(:translations).includes(:events)
  end
end
