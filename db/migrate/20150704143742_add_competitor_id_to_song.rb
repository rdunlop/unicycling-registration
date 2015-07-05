class AddCompetitorIdToSong < ActiveRecord::Migration
  def change
    add_reference :songs, :competitor, index: { unique: true }
  end
end
