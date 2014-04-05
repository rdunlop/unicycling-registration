class SongsController < ApplicationController
  load_and_authorize_resource

  # GET /songs
  def index
    @songs = Song.all
  end

  # GET /songs/1
  def show
  end

  # GET /songs/new
  def new
    @song = Song.new
  end

  # GET /songs/1/edit
  def edit
  end

  # POST /songs
  def create
    @song = Song.new(song_params)
    @song.registrant = Registrant.first

    if @song.save
      redirect_to @song, notice: 'Song was successfully created.'
    else
      render action: 'new'
    end
  end

  # PATCH/PUT /songs/1
  def update
    if @song.update(song_params)
      redirect_to @song, notice: 'Song was successfully updated.'
    else
      render action: 'edit'
    end
  end

  # DELETE /songs/1
  def destroy
    @song.destroy
    redirect_to songs_url, notice: 'Song was successfully destroyed.'
  end

  private
    # Only allow a trusted parameter "white list" through.
    def song_params
      params.require(:song).permit(:description, :song_file_name, :remove_song_file_name)
    end
end
