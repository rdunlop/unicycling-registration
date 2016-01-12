class CompetitionSetup::BaseCompetitionSetupController < ApplicationController
  before_action :authenticate_user!
  before_action :set_breadcrumb

  layout "competition_setup"

  private

  def set_breadcrumb
    add_breadcrumb "Competition Setup", competition_setup_path
  end
end
