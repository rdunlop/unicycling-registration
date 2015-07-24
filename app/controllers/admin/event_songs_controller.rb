class Admin::EventSongsController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_music_admin
  before_action :add_breadcrumbs

  # GET /event_songs
  def index
    @events = Event.music_uploadable
  end

  # GET /event_songs/:id
  def show
    # Show songs which are not yet assigned to a competitor
    @event = Event.find(params[:id])
    add_breadcrumb "#{@event} Music"
    @songs = Song.where(competitor: nil, event: @event)
  end

  # GET /event_songs/all
  def all
    add_breadcrumb "All Music"
    @songs = Song.all
  end

  private

  def authorize_music_admin
    authorize current_user, :manage_music?
  end

  def add_breadcrumbs
    add_breadcrumb "Music", event_songs_path
  end
end
