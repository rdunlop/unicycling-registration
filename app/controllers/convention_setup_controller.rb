class ConventionSetupController < ApplicationController
  before_action :set_breadcrumb

  private

  def set_breadcrumb
    add_breadcrumb "Convention Setup", event_configuration_path
  end

  def set_categories_breadcrumb
    add_breadcrumb "Event Categories", convention_setup_categories_path
  end
end
