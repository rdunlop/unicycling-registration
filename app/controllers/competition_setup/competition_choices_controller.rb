class CompetitionSetup::CompetitionChoicesController < CompetitionSetup::BaseCompetitionSetupController
  before_action :authenticate_user!
  before_action :authorize_director_management
  before_action :load_event
  before_action :set_competition_choices_breadcrumb

  # GET /competition_setup/events/1/competition_choices
  def index
  end

  def freestyle
  end

  def individual
  end

  def pairs
  end

  def group
  end

  def standard_skill
  end

  def high_long
  end

  def timed
  end

  def multi_lap
  end

  def slow
  end

  def points
  end

  def flatland
  end

  def street
  end

  def overall_champion
  end

  def custom
  end

  # Download a sample data file.
  def download_file
    filename = validate_file(params[:filename])
    return unless filename.present?
    send_file(
      "#{Rails.root}/public/sample_data/#{filename}",
      filename: filename
    )
  end

  private

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
end
