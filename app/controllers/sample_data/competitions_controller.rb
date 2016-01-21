class SampleData::CompetitionsController < SampleData::BaseController
  # GET /sample_data/competitions
  def index
  end

  # Create a fake competition
  # POST /sample_data/competitions
  def create
    competition_type = params[:competition_type]
    case competition_type
    when "Artistic Freestyle IUF 2015"
      name = "#{competition_type} #{Faker::Hipster.word}"
      Competition.create!(
        name: name,
        event: Event.first,
        scoring_class: competition_type,
        award_title_name: name
      )
    end
    flash[:notice] = "Sample Competition Created"
    redirect_to sample_data_competitions_path
  rescue ActiveRecord::RecordInvalid => invalid
    flash[:alert] = "Error creating record: #{invalid}"
    redirect_to sample_data_competitions_path
  end
end
