class EventCategoriesController < ApplicationController
  before_action :set_breadcrumb, only: [:sign_ups]

  respond_to :html

  def sign_ups
    @event_category = EventCategory.find(params[:id])
    authorize @event_category
    add_breadcrumb "#{@event_category} Sign-Ups"

    respond_to do |format|
      format.html
      format.pdf { render_common_pdf "show" }
    end
  end

  private

  def set_breadcrumb
    add_breadcrumb "Events Report", summary_events_path
  end
end
