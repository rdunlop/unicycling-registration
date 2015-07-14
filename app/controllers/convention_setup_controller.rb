class ConventionSetupController < ApplicationController
  before_action :authenticate_user!
  before_action :set_breadcrumb

  layout "convention_setup"

  def index
    authorize @config, :setup_convention?
  end

  private

  def set_breadcrumb
    add_breadcrumb "Convention Setup", convention_setup_path
  end

  def set_categories_breadcrumb
    add_breadcrumb "Event Categories", convention_setup_categories_path
  end
end
