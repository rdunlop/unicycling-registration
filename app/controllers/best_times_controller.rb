class BestTimesController < ApplicationController
  before_action :load_and_authorize_event_category
  before_action :add_breadcrumbs

  def index
    @registrants = @event_category.signed_up_registrants
  end

  # AJAX request to update a best time
  def update
    @registrant_best_time = RegistrantBestTime.find_or_initialize_by(event: @event, registrant_id: params[:id])

    @registrant_best_time.update_attributes(registrant_best_time_params)
    @registrant_best_time.save
    # Format JS
  end

  def destroy
    @registrant_best_time = RegistrantBestTime.find(params[:id])
    @registrant_best_time.destroy
    @registrant = @registrant_best_time.registrant
  end

  private

  def add_breadcrumbs
    add_breadcrumb "Events Report", summary_events_path
    add_breadcrumb "#{@event_category} Best Times"
  end

  def load_and_authorize_event_category
    @event_category = EventCategory.find(params[:event_category_id])
    @event = @event_category.event
    authorize @event_category, :sign_ups?
  end

  def registrant_best_time_params
    params.require(:registrant_best_time).permit(:source_location, :formatted_value)
  end
end
