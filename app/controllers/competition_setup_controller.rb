class CompetitionSetupController < ApplicationController
  before_action :set_breadcrumb

  def index
    authorize! :read, :competition_setup

    @categories = Category.includes(:translations).includes(:events)
  end

  private

  def set_breadcrumb
    add_breadcrumb "Competition Setup", competition_setup_path
  end
end
