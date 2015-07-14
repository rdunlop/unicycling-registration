class CompetitionSetupController < ApplicationController
  before_action :authenticate_user!
  before_action :set_breadcrumb

  def index
    authorize @config, :setup_competition?

    @categories = Category.includes(:translations).includes(:events)
  end

  private

  def set_breadcrumb
    add_breadcrumb "Competition Setup", competition_setup_path
  end
end
