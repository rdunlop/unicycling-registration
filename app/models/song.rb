class Song < ActiveRecord::Base
    mount_uploader :song_file_name, MusicUploader

    belongs_to :registrant

    def human_name
      File.basename(song_file_name.path)
    end
end
