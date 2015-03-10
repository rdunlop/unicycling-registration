class VolunteerOpportunitiesController < ConventionSetupController
  before_action :authenticate_user!
  load_and_authorize_resource
  before_action :add_breadcrumbs

  def index
    @volunteers = Registrant.active.where(volunteer: true)
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
    add_breadcrumb "#{@volunteer_opportunity} Volunteers"
  end

  def update
    respond_to do |format|
      if @volunteer_opportunity.update_attributes(volunteer_opportunity_params)
        format.html { redirect_to(@volunteer_opportunity, :notice => 'Volunteer Opportunity was successfully updated.') }
      else
        format.html { render :action => "edit" }
      end
    end
  end

  def destroy
    @volunteer_opportunity.destroy

    respond_to do |format|
      format.html { redirect_to volunteer_opportunities_path }
      format.json { head :ok }
    end
  end

  private

  def add_breadcrumbs
    add_breadcrumb "Volunteer Opportunities", volunteer_opportunities_path
  end

  def volunteer_opportunity_params
    params.require(:volunteer_opportunity).permit(:description, :display_order, :inform_emails)
  end
end
