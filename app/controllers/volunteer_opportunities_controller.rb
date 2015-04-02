class VolunteerOpportunitiesController < ApplicationController
  before_action :authenticate_user!
  load_and_authorize_resource

  def show
    add_breadcrumb "#{@volunteer_opportunity} Volunteers"
  end
end
