class ConventionSetupController < ApplicationController
  before_action :set_breadcrumb

  def index
    authorize! :read, :convention_setup
  end

  private

  def set_breadcrumb
    add_breadcrumb "Convention Setup", convention_setup_path
  end

  def set_categories_breadcrumb
    add_breadcrumb "Event Categories", convention_setup_categories_path
  end
end
