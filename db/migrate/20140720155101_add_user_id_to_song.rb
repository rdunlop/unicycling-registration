class AddUserIdToSong < ActiveRecord::Migration
  class Registrant < ActiveRecord::Base
  end

  class Song < ActiveRecord::Base
    belongs_to :registrant
  end

  def up
    add_column :songs, :user_id, :integer
    Song.reset_column_information

    Song.all.each do |song|
      song.update_column(:user_id, song.registrant.user_id)
    end
  end

  def down
    remove_column :songs, :user_id
  end
end
