class Admin::EventSongsController < ApplicationController
  authorize_resource class: false
  before_action :add_breadcrumbs

  # GET /event_songs
  def index
    @event = Event.music_uploadable
  end

  # GET /event_songs/:id
  def show
    # Show songs which are not yet assigned to a competitor
    @event = Event.find(params[:id])
    @songs = Song.where(competitor: nil, event: @event)
  end

  private

  def add_breadcrumbs
    add_breadcrumb "Music"
  end
end
