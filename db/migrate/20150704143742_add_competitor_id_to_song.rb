class AddCompetitorIdToSong < ActiveRecord::Migration[4.2]
  def change
    add_reference :songs, :competitor, index: { unique: true }
  end
end
