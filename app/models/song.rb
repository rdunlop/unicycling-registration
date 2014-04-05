class Song < ActiveRecord::Base
    mount_uploader :song_file_name, MusicUploader

    belongs_to :registrant
end
