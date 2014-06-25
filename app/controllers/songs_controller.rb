class SongsController < ApplicationController

  load_and_authorize_resource :registrant, :only => [:index, :create]
  load_and_authorize_resource :through => :registrant, :only => [:create]
  load_and_authorize_resource :except => [:create]
  before_action :load_songs, :only => [:index, :create, :add_file]

  before_action :set_breadcrumbs, :except => [:list]

  def set_breadcrumbs
    @registrant ||= @song.registrant
    add_registrant_breadcrumb(@registrant)
    add_breadcrumb "Songs", registrant_songs_path(@registrant)
  end

  def load_songs
    @registrant ||= @song.registrant
    @songs = @registrant.songs
  end

  # GET /registrants/1/songs
  def index
    add_breadcrumb "Songs"
    @song = Song.new
  end

  # GET /songs/list
  def list
  end

  # GET /songs/1/add_file
  def add_file
    add_breadcrumb "#{@song.event} - Add File"
    if @song.song_file_name.present?
      redirect_to registrant_songs_path(@song.registrant), alert: "Song already associated, please destroy and re-create if you need to change the music"
    end
    @uploader = @song.song_file_name
    @uploader.success_action_redirect = file_complete_song_url(@song)
  end

  # GET /songs/1/file_complete
  def file_complete
    @song.key = params[:key]
    if @song.save
      redirect_to registrant_songs_path(@song.registrant), notice: "File was uploaded"
    else
      redirect_to registrant_songs_path(@song.registrant), alert: "File was not uploaded"
    end
  end

  # POST /registrants/1/songs
  def create
    if @song.save
      redirect_to add_file_song_path(@song), notice: 'Entry created. Please Add a Music File.'
    else
      render action: 'index'
    end
  end

  # DELETE /songs/1
  def destroy
    # destroys the song file on S3
    @song.remove_song_file_name!
    reg = @song.registrant
    @song.destroy
    redirect_to registrant_songs_path(reg), notice: 'Song was successfully deleted.'
  end

  private
    # Only allow a trusted parameter "white list" through.
    def song_params
      params.require(:song).permit(:description, :event_id, :song_file_name)
    end
end
