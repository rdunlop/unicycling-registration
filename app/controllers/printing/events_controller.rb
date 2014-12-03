class Printing::EventsController < ApplicationController
  before_filter :authenticate_user!
  authorize_resource :event, :parent => false

  before_filter :load_event

  def load_event
    @event = Event.find(params[:id])
  end

  def results
    @competitions = @event.competitions

    @no_page_breaks = true # unless params[:no_page_breaks].nil?
    attachment = "attachment" unless params[:attachment].nil?

    name = "#{@config.short_name.tr(" ", "_")}_#{@event.name.tr(" ", "_")}_results"

    respond_to do |format|
      format.html
      format.pdf { render_common_pdf(name, "Portrait", attachment) }
    end
  end
end

