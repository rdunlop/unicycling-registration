class SongsController < ApplicationController

  load_and_authorize_resource :registrant, :only => [:index, :create]
  load_and_authorize_resource

  # GET /registrants/1/songs
  def index
    @songs = @registrant.songs
    @song = Song.new
  end

  # GET /songs/1/add_file
  def add_file
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

  # GET /songs/1/edit
  def edit
  end

  # POST /registrants/1/songs
  def create
    @song = Song.new(song_params)
    @song.registrant = @registrant

    if @song.save
      redirect_to add_file_song_path(@song), notice: 'Song was successfully created.'
    else
      @songs = @registrant.songs
      render action: 'index'
    end
  end

  # PATCH/PUT /songs/1
  def update
    registrant = @song.registrant
    if @song.update(song_params)
      redirect_to registrant_songs_path(registrant), notice: 'Song was successfully updated.'
    else
      render action: 'edit'
    end
  end

  # DELETE /songs/1
  def destroy
    # destroys the song file on S3
    @song.remove_song_file_name!
    reg = @song.registrant
    @song.destroy
    redirect_to registrant_songs_path(reg), notice: 'Song was successfully destroyed.'
  end

  private
    # Only allow a trusted parameter "white list" through.
    def song_params
      params.require(:song).permit(:description, :event_id, :song_file_name)
    end
end
