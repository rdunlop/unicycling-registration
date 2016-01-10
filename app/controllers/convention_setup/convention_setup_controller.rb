class ConventionSetup::ConventionSetupController < ConventionSetup::BaseConventionSetupController
  def index
    authorize @config, :setup_convention?
  end

  def costs
    authorize @config, :setup_convention?
  end
end
