class SongsController < ApplicationController

  load_and_authorize_resource :registrant, :only => [:index, :create]
  load_and_authorize_resource

  # GET /registrants/1/songs
  def index
    @songs = @registrant.songs
    @song = Song.new
  end

  # GET /songs/1/edit
  def edit
  end

  # POST /registrants/1/songs
  def create
    @song = Song.new(song_params)
    @song.registrant = @registrant

    if @song.save
      redirect_to registrant_songs_path(@registrant), notice: 'Song was successfully created.'
    else
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
    reg = @song.registrant
    @song.destroy
    redirect_to registrant_songs_path(reg), notice: 'Song was successfully destroyed.'
  end

  private
    # Only allow a trusted parameter "white list" through.
    def song_params
      params.require(:song).permit(:description, :song_file_name)
    end
end
