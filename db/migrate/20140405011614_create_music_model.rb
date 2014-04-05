class CreateMusicModel < ActiveRecord::Migration
  def change
    remove_column :registrant_choices, :music, :string
    create_table :songs do |t|
      t.integer :registrant_id
      t.string  :description
      t.string  :song_file_name
      t.timestamps
    end
  end
end
