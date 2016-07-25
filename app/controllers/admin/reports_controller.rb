class Admin::ReportsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_breadcrumbs

  def index
    authorize current_user, :registrant_information?
  end

  private

  def set_breadcrumbs
    add_breadcrumb "Reports", reports_path
  end
end
