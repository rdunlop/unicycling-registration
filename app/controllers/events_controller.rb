# == Schema Information
#
# Table name: events
#
#  id                          :integer          not null, primary key
#  category_id                 :integer
#  position                    :integer
#  created_at                  :datetime
#  updated_at                  :datetime
#  name                        :string(255)
#  visible                     :boolean          default(TRUE), not null
#  accepts_music_uploads       :boolean          default(FALSE), not null
#  artistic                    :boolean          default(FALSE), not null
#  accepts_wheel_size_override :boolean          default(FALSE), not null
#  event_categories_count      :integer          default(0), not null
#  event_choices_count         :integer          default(0), not null
#  best_time_format            :string           default("none"), not null
#
# Indexes
#
#  index_events_category_id                     (category_id)
#  index_events_on_accepts_wheel_size_override  (accepts_wheel_size_override)
#

class EventsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_breadcrumb, only: [:summary]

  respond_to :html

  # GET /events/summary
  def summary
    @events = Event.all
    authorize Event.new
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
    authorize Event.new
    @volunteers = Registrant.active.where(volunteer: true)
  end

  # GET /events/specific_volunteers/:volunteer_opportunity_id
  def specific_volunteers
    authorize Event.new
    @volunteer_opportunity = VolunteerOpportunity.find(params[:volunteer_opportunity_id])
  end

  def sign_ups
    @event = Event.find(params[:id])
    authorize @event
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
