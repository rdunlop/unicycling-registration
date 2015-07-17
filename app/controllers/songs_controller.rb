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
      flash[:notice] = "File was uploaded"
    else
      flash[:alert] = "File was not uploaded"
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
    @registrant = Registrant.find_by(bib_number: params[:registrant_id])
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
