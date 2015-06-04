class EventCategoriesController < ApplicationController
  before_action :authenticate_user!
  load_and_authorize_resource

  before_action :load_event_category, only: [:sign_ups]

  before_action :set_breadcrumb, only: [:sign_ups]

  respond_to :html

  def sign_ups
    add_breadcrumb "#{@event_category} Sign-Ups"

    respond_to do |format|
      format.html
      format.pdf { render_common_pdf "show" }
    end
  end

  private

  def load_event_category
    @event_category = EventCategory.find(params[:id])
  end

  def set_breadcrumb
    add_breadcrumb "Events Report", summary_events_path
  end
end

