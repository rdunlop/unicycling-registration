class AddMusicToEvent < ActiveRecord::Migration[4.2]
  def change
    add_column :events, :accepts_music_uploads, :boolean, default: false
  end
end
