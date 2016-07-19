class Admin::CompetitionSongsController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_music_admin

  # GET /competition_songs/:competition_id
  def show
    @competition = Competition.find(params[:competition_id])

    add_breadcrumb "Manage Music", event_songs_path
    add_breadcrumb "#{@competition} Songs"

    # List of all songs for any registrant in this competition
    # But also filter by event
    registrants = @competition.registrants
    @songs = Song.where(registrant: registrants, event: @competition.event)
  end

  # POST /competition_songs/:competition_id
  def create
    competition = Competition.find(params[:competition_id])

    song = Song.find(params[:song_id])
    competitor = Competitor.find(params[:competitor_id])
    existing_song = Song.find_by(competitor: competitor)
    song.competitor = competitor
    Song.transaction do
      if existing_song
        existing_song.update(competitor: nil)
        flash[:notice] = "Un-Assigned A different song, and assigned new song"
      end

      if song.save
        flash[:notice] = "Assigned #{competitor} to #{song.description}"
      else
        flash[:alert] = "Error assigning #{competitor} to #{song.description}. #{song.errors.full_messages.join(', ')}"
      end
    end

    redirect_to competition_song_path(competition)
  end

  # GET /competition_songs/:competition_id/download_zip
  def download_zip
    competition = Competition.find(params[:competition_id])
    zip_creator = MusicZipCreator.new(competition)
    filename = 'music_files-' + competition.to_s.gsub(/[^0-9a-zA-Z]/, '') + '.zip'
    zip_creator.zip_file(filename) do |zip_file|
      send_data(zip_file, type: 'application/zip', filename: filename)
    end
  end

  private

  def authorize_music_admin
    authorize current_user, :manage_music?
  end
end
