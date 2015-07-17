class ConventionSetup::VolunteerOpportunitiesController < ConventionSetupController
  include SortableObject

  before_action :authorize_setup
  before_action :load_volunteer_opportunity, except: [:index, :create]
  before_action :add_breadcrumbs

  def index
    @volunteer_opportunities = VolunteerOpportunity.all
  end

  def new
    add_breadcrumb "New Volunteer Opportunity"
  end

  # POST volunteer_opportunities
  def create
    @volunteer_opportunity = VolunteerOpportunity.new(volunteer_opportunity_params)
    if @volunteer_opportunity.save
      redirect_to convention_setup_volunteer_opportunities_path, notice: 'Volunteer Opportunity was successfully created.'
    else
      render :new
    end
  end

  def update
    if @volunteer_opportunity.update_attributes(volunteer_opportunity_params)
      redirect_to convention_setup_volunteer_opportunities_path, notice: 'Volunteer Opportunity was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @volunteer_opportunity.destroy

    redirect_to convention_setup_volunteer_opportunities_path
  end

  private

  def authorize_setup
    authorize @config, :setup_convention?
  end

  def load_volunteer_opportunity
    @volunteer_opportunity = VolunteerOpportunity.find(params[:id])
  end

  def sortable_object
    VolunteerOpportunity.find(params[:id])
  end

  def add_breadcrumbs
    add_breadcrumb "Volunteer Opportunities", convention_setup_volunteer_opportunities_path
  end

  def volunteer_opportunity_params
    params.require(:volunteer_opportunity).permit(:description, :inform_emails)
  end
end
