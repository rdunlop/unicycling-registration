class Admin::SongsController < ApplicationController
  load_and_authorize_resource class: false

  # GET /songs/list
  def list
    @songs = Song.all
  end

end
