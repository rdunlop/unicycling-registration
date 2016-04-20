# == Schema Information
#
# Table name: songs
#
#  id             :integer          not null, primary key
#  registrant_id  :integer
#  description    :string(255)
#  song_file_name :string(255)
#  created_at     :datetime
#  updated_at     :datetime
#  event_id       :integer
#  user_id        :integer
#  competitor_id  :integer
#
# Indexes
#
#  index_songs_on_competitor_id                           (competitor_id) UNIQUE
#  index_songs_on_user_id_and_registrant_id_and_event_id  (user_id,registrant_id,event_id) UNIQUE
#  index_songs_registrant_id                              (registrant_id)
#

class SongsController < ApplicationController
  before_action :authenticate_user!
  before_action :load_and_authorize_song, only: [:add_file, :file_complete, :destroy]

  before_action :load_registrant_by_bib_number, only: [:index, :create]
  before_action :load_songs, only: [:index, :create]

  before_action :load_user, only: [:my_songs, :create_guest_song]
  before_action :load_user_songs, only: [:my_songs, :create_guest_song]

  before_action :set_breadcrumbs, except: [:my_songs, :create_guest_song]

  # GET /registrants/1/songs
  def index
    @song = Song.new
    authorize @song
  end

  # GET /users/#/my_songs
  def my_songs
    @songs = @user.songs
    @song = Song.new(user: @user)
    authorize @song
  end

  def create_guest_song
    @song = Song.new(song_params)
    @song.user = @user
    authorize @song
    if @song.save
      redirect_to add_file_song_path(@song), notice: 'Entry created. Please Add a Music File.'
    else
      @songs = @user.songs
      render :my_songs
    end
  end

  # GET /songs/1/add_file
  def add_file
    add_breadcrumb "#{@song.event} - Add File"
    if @song.has_file?
      redirect_to registrant_songs_path(@song.registrant), alert: "Song already associated, please destroy and re-create if you need to change the music"
    end
  end

  # PUT /songs/1/file_complete
  def file_complete
    @song.song_file_name = params[:song_file][:song_file_name]

    if @song.save
      flash[:notice] = "File was uploaded"
    else
      flash[:alert] = "File was not uploaded. " + @song.errors.full_messages.join(", ")
    end

    if @song.uploaded_by_guest?
      return_path = my_songs_user_songs_path(@song.user)
    else
      return_path = registrant_songs_path(@song.registrant)
    end

    redirect_to return_path
  end

  # POST /registrants/1/songs
  def create
    @song = @registrant.songs.build(song_params)
    @song.user = @song.registrant.user
    authorize @song
    if @song.save
      redirect_to add_file_song_path(@song), notice: 'Entry created. Please Add a Music File.'
    else
      @songs = @registrant.songs
      render action: 'index'
    end
  end

  # DELETE /songs/1
  def destroy
    # destroys the song file on S3
    @song.remove_song_file_name!

    if @song.uploaded_by_guest?
      return_path = my_songs_user_songs_path(@song.user)
    else
      return_path = registrant_songs_path(@song.registrant)
    end

    @song.destroy
    redirect_to return_path, notice: 'Song was successfully deleted.'
  end

  private

  def load_registrant_by_bib_number
    @registrant = Registrant.find_by!(bib_number: params[:registrant_id])
  end

  def load_user
    @user = User.find(params[:user_id])
  end

  def load_and_authorize_song
    @song = Song.find(params[:id])
    authorize @song
  end

  def load_songs
    @songs = @registrant.songs
  end

  def load_user_songs
    @songs = @user.songs
  end

  # Only allow a trusted parameter "white list" through.
  def song_params
    params.require(:song).permit(:description, :event_id, :song_file_name, :registrant_id)
  end

  def set_breadcrumbs
    @registrant ||= @song.registrant
    add_registrant_breadcrumb(@registrant)
    add_breadcrumb "Songs", registrant_songs_path(@registrant)
  end
end
