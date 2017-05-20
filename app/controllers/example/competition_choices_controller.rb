class Example::CompetitionChoicesController < ApplicationController
  before_action :set_priviledge_if_event_scoped
  layout :event_scoped_or_public
  before_action :set_action_breadcrumb, unless: :index

  # GET /competition_setup/events/1/competition_choices
  def index; end

  def freestyle; end

  def individual
    add_breadcrumb "Freestyle", freestyle_example_competition_choices_path
  end

  def pairs
    add_breadcrumb "Freestyle", freestyle_example_competition_choices_path
  end

  def group
    add_breadcrumb "Freestyle", freestyle_example_competition_choices_path
  end

  def standard_skill; end

  def high_long; end

  def timed; end

  def points; end

  def flatland; end

  def street; end

  def overall_champion; end

  def custom; end

  # Download a sample data file.
  def download_file
    filename = validate_file(params[:filename])
    return if filename.blank?
    send_file(
      "#{Rails.root}/public/sample_data/#{filename}",
      filename: filename
    )
  end

  private

  # If we are being invoked within a /event/:id/competition_choices scope
  # we should ensure that we are allowed to be there
  def set_priviledge_if_event_scoped
    if params[:event_id]
      authenticate_user!
      authorize_director_management
      load_event
      add_breadcrumb "Competition Setup", competition_setup_path
      set_competition_choices_breadcrumb
    else
      # If from the public, allow anyone to view these end-points
      skip_authorization
      add_breadcrumbs
    end
  end

  def event_scoped_or_public
    if params[:event_id]
      "competition_setup"
    end
  end

  def set_competition_choices_breadcrumb
    add_breadcrumb "Competition Choices", event_competition_choices_path(@event)
  end

  # Internal: ensure that the specified filename is one of the
  # expected filenames
  def validate_file(filename)
    allowed_names = [
      "heats_shortest-time-pop-up.evt",
      "sample_competition_registrants.csv",
      "heat_01.lif"
    ]
    return filename if allowed_names.include?(filename)
  end

  def authorize_director_management
    authorize @config, :setup_competition?
  end

  def load_event
    @event = Event.find(params[:event_id])
  end

  def add_breadcrumbs
    add_breadcrumb "Features", example_description_path
    add_breadcrumb "Scoring", example_competition_choices_path
  end

  def set_action_breadcrumb
    add_breadcrumb action_name.titleize
  end
end
