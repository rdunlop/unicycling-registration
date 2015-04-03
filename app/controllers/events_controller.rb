class EventsController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource

  before_action :set_breadcrumb, only: [:summary]

  respond_to :html

  # This should move somewhere else
  # GET /events
  def index
    @categories = Category.includes(:translations).includes(:events)
    respond_with(@categories)
  end

  # GET /events/summary
  def summary
    @num_male_competitors = Registrant.active.competitor.where({:gender => "Male"}).count
    @num_female_competitors = Registrant.active.competitor.where({:gender => "Female"}).count
    @num_competitors = @num_male_competitors + @num_female_competitors

    @num_male_noncompetitors = Registrant.active.notcompetitor.where({:gender => "Male"}).count
    @num_female_noncompetitors = Registrant.active.notcompetitor.where({:gender => "Female"}).count
    @num_noncompetitors = @num_male_noncompetitors + @num_female_noncompetitors

    @num_spectators = Registrant.active.spectator.count

    @num_male_registrants = @num_male_competitors + @num_male_noncompetitors
    @num_female_registrants = @num_female_competitors + @num_female_noncompetitors
    @num_registrants = @num_competitors + @num_noncompetitors + @num_spectators

    @volunteer_opportunities = VolunteerOpportunity.all
  end

  # GET /events/general_volunteers/
  def general_volunteers
    @volunteers = Registrant.active.where(volunteer: true)
  end

  # GET /events/specific_volunteers/:volunteer_opportunity_id
  def specific_volunteers
    @volunteer_opportunity = VolunteerOpportunity.find(params[:volunteer_opportunity_id])
  end

  def sign_ups
    add_category_breadcrumb(@event.category)
    add_event_breadcrumb(@event)
    add_breadcrumb "Sign Ups"
    respond_to do |format|
      format.html
      format.pdf { render_common_pdf "show" }
    end
  end

  # GET /events/1
  def show
    add_category_breadcrumb(@event.category)
    add_event_breadcrumb(@event)
  end

  # POST /events/1/create_director
  def create_director
    user = User.find(params[:user_id])
    user.add_role(:director, @event)

    redirect_to event_path(@event), notice: 'Created Director'
  end

  # DELETE /events/1/destroy_director
  def destroy_director
    user = User.find(params[:user_id])
    user.remove_role(:director, @event)

    redirect_to event_path(@event), notice: 'Removed Director'
  end

  private

  def set_breadcrumb
    add_breadcrumb "Events Report"
  end
end
