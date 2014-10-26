class SongsController < ApplicationController
  load_resource :registrant, find_by: :bib_number, only: [:index, :create]
  authorize_resource :registrant, only: [:index, :create]
  load_and_authorize_resource :through => :registrant, :only => [:create]
  load_and_authorize_resource :user, only: [:my_songs, :create_guest_song]
  load_and_authorize_resource :except => [:create, :my_songs]
  before_action :load_songs, :only => [:index, :create, :add_file]

  before_action :set_breadcrumbs, :except => [:list, :my_songs, :create_guest_song]

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

  # GET /users/#/my_songs
  def my_songs
    @songs = @user.songs
    @song = Song.new
  end

  def create_guest_song
    @song = Song.new(song_params)
    @song.user = @user
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
    @song.user = @song.registrant.user
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

    if @song.uploaded_by_guest?
      return_path = my_songs_user_songs_path(@song.user)
    else
      return_path = registrant_songs_path(@song.registrant)
    end

    @song.destroy
    redirect_to return_path, notice: 'Song was successfully deleted.'
  end

  private
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
