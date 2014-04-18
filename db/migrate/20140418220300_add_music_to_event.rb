class AddMusicToEvent < ActiveRecord::Migration
  def change
    add_column :events, :accepts_music_uploads, :boolean, default: false
  end
end
