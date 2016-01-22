class SampleData::CompetitionsController < SampleData::BaseController
  # GET /sample_data/competitions
  def index
  end

  # Create a fake competition
  # POST /sample_data/competitions
  def create
    competition_type = params[:competition_type]

    creator = SampleCompetitionCreator.new(competition_type)
    if creator.create
      flash[:notice] = "Sample Competition Created"
    else
      flash[:alert] = "Error creating record: #{creator.errors}"
    end
    redirect_to sample_data_competitions_path
  end
end
