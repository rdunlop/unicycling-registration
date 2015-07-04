class Admin::EventSongsController < ApplicationController
  authorize_resource class: false

  # GET /event_songs
  def index
    @event = Event.music_uploadable
  end

  # GET /event_songs/:id
  def show
    @event = Event.find(params[:id])
    @songs = Song.where(event: @event)
  end

  # PUT /event_songs/:id
  def create
    @event = Event.find(params[:event_id])

    @song = Song.find(params[:song_id])
    competitor = Competitor.find(params[:competitor_id])
    @song.competitor = competitor
    if @song.save
      flash[:notice] = "Assigned #{competitor} to #{@song}"
    else
      flash[:alert] = "Error assigning #{@competitor} to #{@song}"
    end

    redirect_to event_song_path(@event)
  end
end
