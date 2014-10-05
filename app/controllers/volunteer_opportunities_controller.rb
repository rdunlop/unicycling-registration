class VolunteerOpportunitiesController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource

  def index
  end

  def new
  end

  # POST volunteer_opportunities
  def create
    respond_to do |format|
      if @volunteer_opportunity.save
        format.html { redirect_to(volunteer_opportunities_path, :notice => 'Volunteer Opportunity was successfully created.') }
      else
        format.html { render :action => "new" }
      end
    end
  end

  def show

  end

  private

  def volunteer_opportunity_params
    params.require(:volunteer_opportunity).permit(:description, :display_order, :inform_emails)
  end
end
