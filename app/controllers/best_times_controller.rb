class BestTimesController < ApplicationController
  before_action :load_and_authorize_event_category

  def show
    @registrants = @event_category.signed_up_registrants
  end

  # AJAX request to update a best time
  def update
    if params[:registrant_best_time][:id].present?
      @registrant_best_time = RegistrantBestTime.find(params[:registrant_best_time][:id])
      @registrant_best_time.update_attributes(registrant_best_time_params)
    else
      @registrant_best_time = RegistrantBestTime.new(registrant_best_time_params)
      @registrant_best_time.event = @event
    end

    @registrant_best_time.save
    # Format JS
  end

  private

  def load_and_authorize_event_category
    @event_category = EventCategory.find(params[:event_category_id])
    @event = @event_category.event
    authorize @event_category, :sign_ups?
  end

  def registrant_best_time_params
    params.require(:registrant_best_time).permit(:source_location, :formatted_value, :registrant_id)
  end
end
