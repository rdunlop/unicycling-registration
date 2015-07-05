class EventsController < ApplicationController
  before_action :authenticate_user!
  load_and_authorize_resource

  before_action :set_breadcrumb, only: [:summary]

  respond_to :html

  # GET /events/summary
  def summary
    @num_male_competitors = Registrant.active.competitor.where(gender: "Male").count
    @num_female_competitors = Registrant.active.competitor.where(gender: "Female").count
    @num_competitors = @num_male_competitors + @num_female_competitors

    @num_male_noncompetitors = Registrant.active.notcompetitor.where(gender: "Male").count
    @num_female_noncompetitors = Registrant.active.notcompetitor.where(gender: "Female").count
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
    add_breadcrumb "Sign Ups"
    respond_to do |format|
      format.html
      format.pdf { render_common_pdf "show" }
    end
  end

  private

  def set_breadcrumb
    add_breadcrumb "Events Report"
  end
end
